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

/**
 * 租户 + 数据范围 Servlet 过滤器
 * <p>
 * 从网关透传的 HTTP 请求头中提取租户、数据范围等信息，写入：
 * <ul>
 *     <li>{@link com.gov.common.tenant.TenantContext} — 租户级 SQL 隔离</li>
 *     <li>{@link com.gov.application.tenant.DataScopeContext} — 行级数据权限</li>
 *     <li>{@link org.slf4j.MDC} — 日志链路中带 tenantId 方便检索</li>
 * </ul>
 * 使用 {@code @Order(1)} 保证在业务 Filter 之前执行，{@code finally} 块确保 ThreadLocal 清理，
 * 防止 Tomcat 线程池复用时出现租户串号。
 * </p>
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