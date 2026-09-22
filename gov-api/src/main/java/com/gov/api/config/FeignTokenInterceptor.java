package com.gov.api.config;

import feign.RequestInterceptor;
import feign.RequestTemplate;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Configuration
public class FeignTokenInterceptor {

    @Bean
    public RequestInterceptor tokenRelayInterceptor() {
        return new RequestInterceptor() {
            @Override
            public void apply(RequestTemplate template) {
                ServletRequestAttributes attrs =
                        (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
                if (attrs == null) {
                    return;
                }
                HttpServletRequest request = attrs.getRequest();

                // 透传关键请求头
                relay(template, request, "Authorization");
                relay(template, request, "X-User-Id");
                relay(template, request, "X-Tenant-Id");
                relay(template, request, "X-Roles");
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