package com.gov.application.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Swagger / OpenAPI 配置（gov-application 服务）。
 *
 * <p>与 gov-auth 的 OpenApiConfig 结构一致，独立配置是因为各微服务单独部署、各自暴露文档。
 *
 * <p><b>关键：把「网关」声明为 server。</b>本服务不解析 JWT，只信任网关注入的
 * {@code X-User-Id} / {@code X-Tenant-Id} 请求头。文档页在 8082 上，若调试请求直连 8082，
 * 即便在 Authorize 里填了 Token 也会返回「未登录」；声明 servers 后请求会发往网关，
 * 由网关校验 JWT 并注入身份。
 *
 * <p>网关地址可用 {@code gov.doc.gateway-url} 覆盖（默认 {@code http://localhost:8090}）。
 */
@Configuration
public class OpenApiConfig {

    @Value("${gov.doc.gateway-url:http://localhost:8090}")
    private String gatewayUrl;

    @Bean
    public OpenAPI govOpenAPI() {
        final String securitySchemeName = "BearerAuth";

        return new OpenAPI()
                .info(new Info()
                        .title("政务管理系统 API（业务服务）")
                        .description("调试请先在认证中心日志登录拿到 token，"
                                + "再点本页右上角 Authorize 填入。"
                                + "请求会经网关转发（服务端口不解析 JWT），网关需处于运行状态。")
                        .version("1.0.0"))
                .servers(List.of(new Server()
                        .url(gatewayUrl)
                        .description("API 网关（服务端口不解析 JWT，必须经网关调用才能拿到登录身份）")))
                .addSecurityItem(new SecurityRequirement().addList(securitySchemeName))
                .components(new Components()
                        .addSecuritySchemes(securitySchemeName,
                                new SecurityScheme()
                                        .name(securitySchemeName)
                                        .type(SecurityScheme.Type.HTTP)
                                        .scheme("bearer")
                                        .bearerFormat("JWT")));
    }
}
