package com.gov.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

/**
 * 网关鉴权配置属性
 * <p>
 * 对应配置前缀 {@code gateway.auth}，目前主要用于维护无需 Token 即可访问的路径白名单。
 * 白名单支持 Ant 风格通配符（如 {@code /api/auth/**}、{@code /public/**}），
 * 由 {@link TenantAuthGlobalFilter} 在鉴权阶段使用。
 * </p>
 *
 * <pre class="code">
 * gateway:
 *   auth:
 *     white-list:
 *       - /api/auth/login
 *       - /api/auth/verify
 *       - /public/**
 * </pre>
 */
@Component
@ConfigurationProperties(prefix = "gateway.auth")
public class AuthProperties {

    /** 免鉴权路径白名单，支持 AntPathMatcher 通配符 */
    private List<String> whiteList = new ArrayList<>();

    public List<String> getWhiteList() {
        return whiteList;
    }

    public void setWhiteList(List<String> whiteList) {
        this.whiteList = whiteList;
    }
}