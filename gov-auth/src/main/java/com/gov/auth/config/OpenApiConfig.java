package com.gov.auth.config;  // gov-application 里改成 com.gov.application.config

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.Components;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Swagger / OpenAPI 配置（gov-auth 服务）
 * <p>
 * 统一设置 API 文档标题、版本，并注册 Bearer JWT 认证方案，
 * 使 Swagger UI 右上角出现 Authorize 按钮，调试时可以直接填 Token。
 * </p>
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI govOpenAPI() {
        final String securitySchemeName = "BearerAuth";

        return new OpenAPI()
                .info(new Info()
                        .title("政务管理系统 API")
                        .description("政务管理微服务接口文档")
                        .version("1.0.0"))
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