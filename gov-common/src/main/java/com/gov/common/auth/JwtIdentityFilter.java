package com.gov.common.auth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.Enumeration;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * 服务端本地校验 JWT 的兜底过滤器。
 *
 * <h3>为什么需要它</h3>
 * <p>本项目的鉴权模型是：**网关解析 JWT → 注入 {@code X-User-Id} / {@code X-Tenant-Id} 等内部头 →
 * 下游服务无条件信任这些头**。服务自身**不解析 JWT**。
 *
 * <p>这个模型有个副作用：**只要请求绕过了网关（直连 8081/8082/8083），
 * 带不带 token 都会被判定为「未登录」**。最典型的受害者就是接口文档页——
 * Knife4j 的「调试」把请求打到服务自身端口（它并不总是采用 OpenAPI 里声明的 servers），
 * 于是在文档页右上角 Authorize 里填了 token 依然到处「未登录」，很难排查。
 *
 * <p>本过滤器补上这一环：当请求头里**没有**网关注入的 {@code X-User-Id}，
 * 但 {@code Authorization} 里带着一个**签名有效**的 JWT 时，就地解析出身份，
 * 并以"改写请求头"的方式注入，使下游所有逻辑（控制器读 {@code X-User-Id}、
 * 各服务的 TenantFilter、{@code @RequiresPerm}）**无需任何改动**即可工作。
 *
 * <h3>安全性</h3>
 * <ul>
 *   <li>只接受**签名校验通过**的 JWT，密钥与网关、gov-auth 共用（{@code gov.jwt.secret}）；伪造 token 无效。</li>
 *   <li>一旦 JWT 有效，**客户端自带的内部身份头一律被覆盖**——与网关的处理方式一致，
 *       因此不存在"用伪造的 {@code X-Tenant-Id} 越权"的问题。</li>
 *   <li>密钥未配置（为空）时本过滤器**完全不生效**，行为与改造前一致。</li>
 *   <li>生产环境若只允许经网关访问，可设 {@code gov.auth.jwt-fallback-enabled=false} 关闭。</li>
 * </ul>
 *
 * <p>执行顺序 {@code -1}：必须早于 {@code TraceServletFilter}(0) 和各服务的 TenantFilter(1)，
 * 这样它们读到的就已经是 JWT 推导出的身份头。
 */
@Component
@Order(-1)
@ConditionalOnProperty(name = "gov.auth.jwt-fallback-enabled", havingValue = "true", matchIfMissing = true)
public class JwtIdentityFilter implements Filter {

    private static final Logger log = LoggerFactory.getLogger(JwtIdentityFilter.class);

    /** 与网关 {@code TenantAuthGlobalFilter#INTERNAL_HEADERS} 保持一致 */
    private static final List<String> IDENTITY_HEADERS = List.of(
            "X-User-Id", "X-Tenant-Id", "X-Roles", "X-Dept-Id", "X-Data-Scope");

    @Value("${gov.jwt.secret:}")
    private String secret;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;

        Map<String, String> identity = resolveIdentity(req);
        if (identity == null) {
            chain.doFilter(request, response);
            return;
        }
        chain.doFilter(new IdentityHeaderRequest(req, identity), response);
    }

    /**
     * 尝试从 Authorization 里的 JWT 推导身份。
     *
     * @return 身份头映射；无 token、密钥未配置或签名校验失败时返回 {@code null}（保持原有行为）
     */
    private Map<String, String> resolveIdentity(HttpServletRequest request) {
        if (secret == null || secret.isBlank()) {
            return null;
        }
        String token = extractToken(request.getHeader("Authorization"));
        if (token == null) {
            return null;
        }
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(key())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            Map<String, String> identity = new LinkedHashMap<>();
            identity.put("X-User-Id", text(claims.get("uid")));
            identity.put("X-Tenant-Id", text(claims.get("tid")));
            identity.put("X-Roles", text(claims.get("roles")));
            identity.put("X-Dept-Id", text(claims.get("did")));
            // 数据权限缺省按最严格的"仅本部门"处理，与网关保持一致
            identity.put("X-Data-Scope", claims.get("ds") == null ? "3" : String.valueOf(claims.get("ds")));
            return identity;
        } catch (Exception e) {
            log.debug("Authorization 中的 token 校验失败，按未认证处理: {}", e.getMessage());
            return null;
        }
    }

    /**
     * 解析 Authorization：兼容 {@code Bearer <token>} 与裸 token
     * （规则与网关 {@code TenantAuthGlobalFilter#extractToken} 保持一致）。
     */
    private String extractToken(String auth) {
        if (auth == null || auth.isEmpty()) {
            return null;
        }
        String value = auth.trim();
        if (value.regionMatches(true, 0, "Bearer ", 0, 7)) {
            String token = value.substring(7).trim();
            return token.isEmpty() ? null : token;
        }
        if (value.indexOf(' ') > 0) {
            return null;
        }
        return value;
    }

    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    private static String text(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    /**
     * 用 JWT 推导出的身份**替换**请求头中的内部身份头。
     * <p>覆盖而非追加：客户端自带的同名头会被丢弃，避免伪造身份生效。</p>
     */
    private static class IdentityHeaderRequest extends HttpServletRequestWrapper {

        private final Map<String, String> identity;

        IdentityHeaderRequest(HttpServletRequest request, Map<String, String> identity) {
            super(request);
            this.identity = identity;
        }

        /** 大小写不敏感地取出本过滤器要覆盖的头名 */
        private String overrideKey(String name) {
            if (name == null) {
                return null;
            }
            for (String key : IDENTITY_HEADERS) {
                if (key.equalsIgnoreCase(name)) {
                    return key;
                }
            }
            return null;
        }

        @Override
        public String getHeader(String name) {
            String key = overrideKey(name);
            return key != null ? identity.get(key) : super.getHeader(name);
        }

        @Override
        public Enumeration<String> getHeaders(String name) {
            String key = overrideKey(name);
            if (key != null) {
                return Collections.enumeration(Collections.singletonList(identity.get(key)));
            }
            return super.getHeaders(name);
        }

        @Override
        public Enumeration<String> getHeaderNames() {
            Set<String> names = new LinkedHashSet<>(Collections.list(super.getHeaderNames()));
            names.addAll(identity.keySet());
            return Collections.enumeration(names);
        }
    }
}
