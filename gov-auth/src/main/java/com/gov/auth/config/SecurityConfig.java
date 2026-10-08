package com.gov.auth.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

/**
 * 安全配置
 * <p>
 * 注册 BCryptPasswordEncoder 作为全局密码编码器。
 * 系统中所有密码的加密与校验都委托给此 Bean，确保使用 BCrypt 算法（自适应盐 + 工作因子）。
 * </p>
 */
@Configuration
public class SecurityConfig {

    /**
     * BCrypt 密码编码器
     * <p>
     * BCrypt 是目前推荐的密码哈希算法，内置随机盐且可通过工作因子抵抗暴力破解。
     * </p>
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}