package com.gov.api.config;

import com.gov.common.tenant.TenantContext;
import com.gov.common.tenant.UserContext;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * Feign 请求上下文透传拦截器
 * <p>
 * 在微服务间通过 Feign 发起调用时，自动将当前请求的关键上下文头透传给下游：
 * <ul>
 *     <li>{@code Authorization} - JWT Token</li>
 *     <li>{@code X-User-Id} - 当前用户 ID</li>
 *     <li>{@code X-Tenant-Id} - 当前租户 ID</li>
 *     <li>{@code X-Roles} - 用户角色</li>
 *     <li>{@code X-Trace-Id} - 全链路追踪 ID</li>
 * </ul>
 *
 * <h3>两种上下文来源</h3>
 * <ol>
 *     <li><b>Web 请求线程</b>：直接从 {@link RequestContextHolder} 中取当前 HttpServletRequest 的头</li>
 *     <li><b>异步/非 Web 线程</b>：从 {@link TenantContext}、{@link com.gov.common.tenant.UserContext}、
 *         {@link MDC} 中取线程本地变量（需确保 {@link com.gov.common.config.AsyncContextConfig} 已正确传播上下文）</li>
 * </ol>
 * 如果两种上下文都缺失，会输出 WARN 日志，提醒开发者检查异步线程的上下文传播。
 * </p>
 */
@Configuration
public class FeignTokenInterceptor {

    private static final Logger log = LoggerFactory.getLogger(FeignTokenInterceptor.class);

    /**
     * 创建请求拦截器 Bean，对每一次 Feign 调用注入上下文头。
     */
    @Bean
    public RequestInterceptor tokenRelayInterceptor() {
        return new RequestInterceptor() {
            @Override
            public void apply(RequestTemplate template) {
                ServletRequestAttributes attrs =
                        (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
                if (attrs != null) {
                    HttpServletRequest request = attrs.getRequest();
                    // Web 请求线程：直接从当前请求透传头
                    relay(template, request, "Authorization");
                    relay(template, request, "X-User-Id");
                    relay(template, request, "X-Tenant-Id");
                    relay(template, request, "X-Roles");
                    relay(template, request, "X-Trace-Id");
                    return;
                }

                // 非 Web 线程：从线程本地上下文获取
                String tenantId = TenantContext.get();
                String userId = UserContext.getUserId();
                String userTenant = UserContext.getTenantId();
                String traceId = MDC.get("traceId");

                boolean hasContext = false;
                if (tenantId != null && !tenantId.isEmpty()) {
                    template.header("X-Tenant-Id", tenantId);
                    hasContext = true;
                } else if (userTenant != null && !userTenant.isEmpty()) {
                    template.header("X-Tenant-Id", userTenant);
                    hasContext = true;
                }
                if (userId != null && !userId.isEmpty()) {
                    template.header("X-User-Id", userId);
                    hasContext = true;
                }
                if (traceId != null && !traceId.isEmpty()) {
                    template.header("X-Trace-Id", traceId);
                }
                if (!hasContext) {
                    log.warn("Feign 调用时既无 RequestContextHolder 也无 TenantContext/UserContext, " +
                            "异步线程/MQ 场景请检查是否正确设置了租户上下文");
                }
            }

            /** 从源请求复制指定头到 Feign 请求模板 */
            private void relay(RequestTemplate template, HttpServletRequest request, String header) {
                String value = request.getHeader(header);
                if (value != null && !value.isEmpty()) {
                    template.header(header, value);
                }
            }
        };
    }
}