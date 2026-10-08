package com.gov.gateway.filter;

import com.gov.gateway.config.AuthProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.data.redis.core.ReactiveStringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;

/**
 * 租户鉴权全局过滤器
 * <p>
 * 网关的核心安全过滤器，order = -100，在 {@link TraceGlobalFilter} 之后执行。
 * 它完成三件事：
 * <ol>
 *     <li><b>白名单放行</b>：匹配 {@link AuthProperties} 配置的免鉴权路径，直接放行</li>
 *     <li><b>Token 校验</b>：解析 JWT、校验签名、检查 Redis 黑名单（登出场景）</li>
 *     <li><b>身份注入</b>：将可信的用户/租户/角色信息以内部头注入下游请求，
 *         同时剥离客户端伪造的同名头，防止身份冒充</li>
 * </ol>
 * 下游微服务通过 {@code X-User-Id}、{@code X-Tenant-Id} 等头获取当前请求的身份上下文，
 * 这些头只能由本过滤器注入，客户端无法伪造。
 * </p>
 *
 * @see TraceGlobalFilter
 * @see AuthProperties
 */
@Component
public class TenantAuthGlobalFilter implements GlobalFilter, Ordered {

    private static final Logger log = LoggerFactory.getLogger(TenantAuthGlobalFilter.class);

    /** JWT 签名密钥，与 auth 服务保持一致 */
    @Value("${gov.jwt.secret}")
    private String secret;

    @Autowired(required = false)
    private AuthProperties authProperties;

    /** 响应式 Redis 客户端，用于查询 Token 黑名单 */
    @Autowired
    private ReactiveStringRedisTemplate reactiveRedis;

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    /**
     * 网关注入、下游无条件信任的内部头。
     * 客户端一律不得自带：进入过滤器时先全部剥离，再由网关按需重新注入。
     * 这是防止客户端伪造身份的关键安全措施。
     */
    private static final List<String> INTERNAL_HEADERS = List.of(
            "X-User-Id", "X-Tenant-Id", "X-Roles", "X-Dept-Id", "X-Data-Scope");

    /** 构造 HMAC-SHA 签名密钥 */
    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /** 剥离客户端伪造的内部身份头，防止身份冒充 */
    private ServerHttpRequest.Builder stripInternalHeaders(ServerWebExchange exchange) {
        return exchange.getRequest().mutate()
                .headers(headers -> INTERNAL_HEADERS.forEach(headers::remove));
    }

    /**
     * 执行鉴权过滤。流程：
     * <ol>
     *     <li>匹配白名单 → 剥离伪造头后直接放行</li>
     *     <li>缺少 Authorization → 返回 401</li>
     *     <li>JWT 解析失败 → 返回 401</li>
     *     <li>Redis 黑名单命中 → 返回 401（已登出）</li>
     *     <li>校验通过 → 剥离伪造头 + 注入可信身份头 → 放行</li>
     * </ol>
     */
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();

        List<String> whiteList = (authProperties == null || authProperties.getWhiteList() == null)
                ? Collections.emptyList()
                : authProperties.getWhiteList();

        log.debug("网关鉴权: path={}, whiteList={}", path, whiteList);

        boolean isWhite = whiteList.stream().anyMatch(p -> pathMatcher.match(p, path));
        if (isWhite) {
            return chain.filter(exchange.mutate()
                    .request(stripInternalHeaders(exchange).build())
                    .build());
        }

        String auth = exchange.getRequest().getHeaders().getFirst("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) {
            return unauthorized(exchange, "缺少 Token");
        }

        Claims claims;
        try {
            claims = Jwts.parser()
                    .verifyWith(key())
                    .build()
                    .parseSignedClaims(auth.substring(7))
                    .getPayload();
        } catch (Exception e) {
            return unauthorized(exchange, "Token 无效或已过期");
        }

        // 从 JWT 载荷中提取身份信息
        String uid = claims.get("uid", String.class);
        String tid = claims.get("tid", String.class);
        String roles = claims.get("roles", String.class);
        String did = claims.get("did", String.class);
        Integer ds = claims.get("ds", Integer.class);

        String blacklistKey = "token:blacklist:" + auth.substring(7);

        String traceId = exchange.getRequest().getHeaders().getFirst("X-Trace-Id");

        return reactiveRedis.hasKey(blacklistKey)
                .flatMap(isBlacklisted -> {
                    if (Boolean.TRUE.equals(isBlacklisted)) {
                        return unauthorized(exchange, "Token 已失效，请重新登录");
                    }
                    // 校验通过：先剥离客户端伪造的内部头，再注入可信上下文
                    ServerHttpRequest.Builder builder = stripInternalHeaders(exchange)
                            .header("X-User-Id", uid == null ? "" : uid)
                            .header("X-Tenant-Id", tid == null ? "" : tid)
                            .header("X-Roles", roles == null ? "" : roles)
                            .header("X-Dept-Id", did == null ? "" : did)
                            .header("X-Data-Scope", ds == null ? "3" : String.valueOf(ds));
                    if (traceId != null && !traceId.isEmpty()) {
                        builder.header("X-Trace-Id", traceId);
                    }
                    return chain.filter(exchange.mutate().request(builder.build()).build());
                });
    }

    /**
     * 构造 401 未授权响应。
     * 对错误消息做 HTML 转义，防止反射型 XSS。
     */
    private Mono<Void> unauthorized(ServerWebExchange exchange, String msg) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(HttpStatus.UNAUTHORIZED);
        response.getHeaders().setContentType(MediaType.APPLICATION_JSON);
        String safeMsg = msg == null ? "" : msg.replace("\"", "\\\"").replace("<", "&lt;").replace(">", "&gt;");
        String body = "{\"code\":401,\"msg\":\"" + safeMsg + "\",\"data\":null}";
        DataBuffer buffer = response.bufferFactory()
                .wrap(body.getBytes(StandardCharsets.UTF_8));
        return response.writeWith(Mono.just(buffer));
    }

    /**
     * 返回 -100，在 {@link TraceGlobalFilter}（-200）之后执行，
     * 确保鉴权阶段的日志也能携带 traceId。
     */
    @Override
    public int getOrder() {
        return -100;
    }
}