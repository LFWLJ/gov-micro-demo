package com.gov.application.tenant;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import com.gov.common.tenant.TenantContext;

import java.io.IOException;

/**
 * 从请求头 X-Tenant-Id 解析租户，放入 ThreadLocal
 * 网关已经校验过 Token 并注入过这个头，这里只负责取用
 */
@Component
@Order(1)
public class TenantFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        String tenantId = req.getHeader("X-Tenant-Id");
        String deptId = req.getHeader("X-Dept-Id");
        String dataScope = req.getHeader("X-Data-Scope");
        String userId = req.getHeader("X-User-Id");
        try {
            TenantContext.set(tenantId);
            DataScopeContext.set(userId, deptId, dataScope);
            chain.doFilter(request, response);
        } finally {
            // 一定要清理，避免线程复用导致串租户
            TenantContext.clear();
            DataScopeContext.clear();
        }
    }


}