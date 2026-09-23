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

@Component
public class TenantAuthGlobalFilter implements GlobalFilter, Ordered {

    private static final Logger log = LoggerFactory.getLogger(TenantAuthGlobalFilter.class);

    @Value("${gov.jwt.secret}")
    private String secret;

    @Autowired(required = false)
    private AuthProperties authProperties;

    @Autowired
    private ReactiveStringRedisTemplate reactiveRedis;

    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getURI().getPath();

        // ★ 安全获取白名单：authProperties 或 whiteList 为 null 时都退化为空列表
        List<String> whiteList = (authProperties == null || authProperties.getWhiteList() == null)
                ? Collections.emptyList()
                : authProperties.getWhiteList();

        log.debug("网关鉴权: path={}, whiteList={}", path, whiteList);

        boolean isWhite = whiteList.stream().anyMatch(p -> pathMatcher.match(p, path));
        if (isWhite) {
            return chain.filter(exchange);
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

        // 4. 先查 Redis 黑名单
        String uid = claims.get("uid", String.class);
        String tid = claims.get("tid", String.class);
        String roles = claims.get("roles", String.class);
        String did = claims.get("did", String.class);
        Integer ds = claims.get("ds", Integer.class);

        String blacklistKey = "token:blacklist:" + auth.substring(7);

        return reactiveRedis.hasKey(blacklistKey)
                .flatMap(isBlacklisted -> {
                    if (Boolean.TRUE.equals(isBlacklisted)) {
                        return unauthorized(exchange, "Token 已失效，请重新登录");
                    }
                    // 5. 不在黑名单，注入用户上下文
                    ServerHttpRequest request = exchange.getRequest().mutate()
                            .header("X-User-Id", uid == null ? "" : uid)
                            .header("X-Tenant-Id", tid == null ? "" : tid)
                            .header("X-Roles", roles == null ? "" : roles)
                            .header("X-Dept-Id", did == null ? "" : did)
                            .header("X-Data-Scope", ds == null ? "3" : String.valueOf(ds))
                            .build();
                    return chain.filter(exchange.mutate().request(request).build());
                });
    }

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


    @Override
    public int getOrder() {
        return -100;
    }
}