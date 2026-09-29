package com.gov.file.config;

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
 * gov-file 的租户/用户上下文过滤器。
 *
 * <p>背景：{@code t_file} / {@code t_attachment} 已纳入 MyBatis-Plus 租户拦截器。
 * 如果不先把网关注入的 {@code X-Tenant-Id} 写入 {@link TenantContext}，
 * 租户拦截器会退化成 {@code tenant_id = '__NONE__'}，导致文件列表查询全部为空。
 * 与 gov-application 的 TenantFilter、gov-auth 的 AuthTenantFilter 保持同一风格。
 */
@Component
@Order(1)
public class TenantFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        String tenantId = req.getHeader("X-Tenant-Id");
        String userId = req.getHeader("X-User-Id");
        try {
            if (tenantId != null && !tenantId.isEmpty()) {
                TenantContext.set(tenantId);
                MDC.put("tenantId", tenantId);
            }
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
