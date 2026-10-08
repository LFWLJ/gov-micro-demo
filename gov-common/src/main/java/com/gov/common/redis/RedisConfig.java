package com.gov.common.redis;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.PropertyAccessor;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.jsontype.BasicPolymorphicTypeValidator;
import com.fasterxml.jackson.databind.jsontype.PolymorphicTypeValidator;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * Redis 序列化配置
 * <p>
 * 自定义 {@link RedisTemplate} 的序列化策略：
 * <ul>
 *   <li><b>Key</b> 使用 {@link StringRedisSerializer} — 避免 Redis 中出现二进制 Key，方便人工排查</li>
 *   <li><b>Value</b> 使用 {@link Jackson2JsonRedisSerializer} — 统一序列化为 JSON，可读性好</li>
 * </ul>
 *
 * <p>安全加固 — 白名单多态反序列化：</p>
 * <p>
 * Jackson 默认启用多态类型信息（{@code activateDefaultTyping}）时存在 Gadget RCE 风险
 * （攻击者向 Redis 写入恶意序列化数据可触发远程代码执行）。此处改用
 * {@link BasicPolymorphicTypeValidator} 按包白名单限制，仅允许本项目实体和常用 JDK 类型
 * 参与反序列化，其余一律拒绝，彻底堵死攻击面。
 * </p>
 */
@Configuration
public class RedisConfig {

    /**
     * 构造安全加固后的 RedisTemplate
     *
     * @param factory Redis 连接工厂（自动注入）
     * @return 配置好的 RedisTemplate，Bean 默认名称为 redisTemplate
     */
    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory factory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(factory);

        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        // 安全：禁止 LaissezFaire 全量多态反序列化（可写 Redis 即可 gadget RCE）
        // 改为按包白名单，仅允许本项目与常用 JDK 类型
        PolymorphicTypeValidator ptv = BasicPolymorphicTypeValidator.builder()
                .allowIfSubType("com.gov.")
                .allowIfSubType("java.util.")
                .allowIfSubType("java.time.")
                .allowIfSubType("java.lang.")
                .build();
        om.activateDefaultTyping(ptv, ObjectMapper.DefaultTyping.NON_FINAL);
        om.registerModule(new JavaTimeModule());

        Jackson2JsonRedisSerializer<Object> jackson =
                new Jackson2JsonRedisSerializer<>(om, Object.class);
        StringRedisSerializer stringSer = new StringRedisSerializer();

        // key 用 String，value 用 JSON
        template.setKeySerializer(stringSer);
        template.setHashKeySerializer(stringSer);
        template.setValueSerializer(jackson);
        template.setHashValueSerializer(jackson);

        template.afterPropertiesSet();
        return template;
    }
}