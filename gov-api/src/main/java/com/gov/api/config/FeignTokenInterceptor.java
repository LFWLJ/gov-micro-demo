package com.gov.api.config;

import com.gov.common.tenant.TenantContext;
import com.gov.common.tenant.UserContext;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Configuration
public class FeignTokenInterceptor {

    private static final Logger log = LoggerFactory.getLogger(FeignTokenInterceptor.class);

    @Bean
    public RequestInterceptor tokenRelayInterceptor() {
        return new RequestInterceptor() {
            @Override
            public void apply(RequestTemplate template) {
                ServletRequestAttributes attrs =
                        (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
                if (attrs != null) {
                    HttpServletRequest request = attrs.getRequest();
                    relay(template, request, "Authorization");
                    relay(template, request, "X-User-Id");
                    relay(template, request, "X-Tenant-Id");
                    relay(template, request, "X-Roles");
                    return;
                }

                String tenantId = TenantContext.get();
                String userId = UserContext.getUserId();
                String userTenant = UserContext.getTenantId();

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
                if (!hasContext) {
                    log.warn("Feign 调用时既无 RequestContextHolder 也无 TenantContext/UserContext, " +
                            "异步线程/MQ 场景请检查是否正确设置了租户上下文");
                }
            }

            private void relay(RequestTemplate template, HttpServletRequest request, String header) {
                String value = request.getHeader(header);
                if (value != null && !value.isEmpty()) {
                    template.header(header, value);
                }
            }
        };
    }
}