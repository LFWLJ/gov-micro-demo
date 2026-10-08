package com.gov.auth.config;

import com.gov.common.tenant.TenantContext;
import com.gov.common.tenant.UserContext;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;

/**
 * gov-auth 服务的租户/用户上下文过滤器
 * <p>
 * 从网关注入的请求头 {@code X-Tenant-Id}、{@code X-User-Id} 中提取上下文，
 * 写入 {@link TenantContext} / {@link UserContext} ThreadLocal，
 * 并把 tenantId 写入 MDC 用于日志打印。
 * </p>
 *
 * <p>与 {@link com.gov.file.config.TenantFilter} 和 gov-application 的 TenantFilter
 * 保持相同的职责分工，但各自放在本服务的 config 包内以避免循环依赖。</p>
 *
 * <p>必须在请求结束时（finally 块）清理 ThreadLocal，
 * 否则 Tomcat 线程池复用时会串租户 / 串用户。</p>
 */
@Component
@Order(1)
public class AuthTenantFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        String tenantId = req.getHeader("X-Tenant-Id");
        String userId = req.getHeader("X-User-Id");
        try {
            // 租户上下文
            if (tenantId != null && !tenantId.isEmpty()) {
                TenantContext.set(tenantId);
                MDC.put("tenantId", tenantId);
            }
            // 用户上下文（gov-common 的 UserContext）
            if (userId != null && !userId.isEmpty()) {
                UserContext.setUserId(userId);
            }
            if (tenantId != null && !tenantId.isEmpty()) {
                UserContext.setTenantId(tenantId);
            }
            chain.doFilter(request, response);
        } finally {
            TenantContext.clear();
            UserContext.clear();
            MDC.remove("tenantId");
        }
    }
}