package com.gov.auth.config;

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
 * Swagger / OpenAPI 配置（gov-auth 服务）。
 *
 * <p>统一设置文档标题、版本，并注册 Bearer JWT 认证方案（右上角 Authorize 按钮）。
 *
 * <p><b>关键：把「网关」声明为 server。</b>
 * 本服务的接口**不解析 JWT**，只信任网关注入的 {@code X-User-Id} / {@code X-Tenant-Id} 请求头
 * （服务端不信任客户端身份，这是刻意设计）。文档页跑在 8081 上，如果调试请求直连 8081，
 * 就没有网关注入身份——**带不带 Token 都会返回「未登录」**。
 * 声明 servers 后，文档页的「调试」会发往网关，由网关校验 JWT 并注入身份，全局 Token 才真正生效。
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
                        .title("政务管理系统 API（认证中心）")
                        .description("调试步骤：① 调用 /api/auth/login 拿到 token；"
                                + "② 点右上角 Authorize 填入 token（不用带 Bearer 前缀，"
                                + "若带了也能识别）；③ 再调其它接口。"
                                + "注意：请求经网关转发，网关必须处于运行状态。")
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
