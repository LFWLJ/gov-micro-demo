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
 * gov-auth 的租户/用户上下文过滤器
 * 从网关注入的请求头中提取 X-Tenant-Id、X-User-Id，写入 ThreadLocal
 * 与 gov-application 的 TenantFilter 保持一致的风格
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