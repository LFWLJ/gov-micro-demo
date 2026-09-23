package com.gov.application.tenant;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import com.gov.common.tenant.TenantContext;

import java.io.IOException;

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
            if (tenantId != null) MDC.put("tenantId", tenantId);
            DataScopeContext.set(userId, deptId, dataScope);
            chain.doFilter(request, response);
        } finally {
            TenantContext.clear();
            MDC.remove("tenantId");
            DataScopeContext.clear();
        }
    }
}