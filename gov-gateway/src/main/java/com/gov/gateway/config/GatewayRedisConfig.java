package com.gov.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.ReactiveRedisConnectionFactory;
import org.springframework.data.redis.core.ReactiveStringRedisTemplate;

/**
 * 网关 Redis 配置
 * <p>
 * 网关基于 Spring Cloud Gateway（WebFlux / Reactive 栈），
 * 因此注入 {@link ReactiveStringRedisTemplate} 而不是阻塞式的 {@code RedisTemplate}，
 * 用于 JWT 黑名单校验、分布式限流等场景。
 * </p>
 */
@Configuration
public class GatewayRedisConfig {

    @Bean
    public ReactiveStringRedisTemplate reactiveStringRedisTemplate(
            ReactiveRedisConnectionFactory factory) {
        return new ReactiveStringRedisTemplate(factory);
    }
}