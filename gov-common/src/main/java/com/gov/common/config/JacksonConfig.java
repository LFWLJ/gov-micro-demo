package com.gov.common.config;

import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalTimeSerializer;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Jackson 日期时间格式统一配置
 * <p>
 * 覆盖 Spring Boot 默认的 ISO 8601 格式（如 {@code 2026-09-21T14:30:00}），
 * 改为中文友好的 {@code yyyy-MM-dd HH:mm:ss} 格式，前后端约定一致。
 * </p>
 *
 * <p>关键实现细节：</p>
 * <p>使用 {@code builder.modulesToInstall(module)} 而不是 {@code builder.modules(module)}。
 * 前者是<b>追加</b>到 Spring Boot 已自动注册的模块集合上，后者是<b>完全替换</b>。
 * 如果误用 modules()，会把 Boot 默认注册的其他模块（如参数名称模块）一起干掉，
 * 导致某些场景反序列化异常。</p>
 */
@Configuration
public class JacksonConfig {

    /** 日期时间格式：2026-09-21 14:30:00 */
    private static final String DATE_TIME_PATTERN = "yyyy-MM-dd HH:mm:ss";

    /** 日期格式：2026-09-21 */
    private static final String DATE_PATTERN = "yyyy-MM-dd";

    /** 时间格式：14:30:00 */
    private static final String TIME_PATTERN = "HH:mm:ss";

    /**
     * 注入自定义 JavaTimeModule，覆盖 LocalDateTime / LocalDate / LocalTime 的序列化行为
     *
     * @return Jackson Builder 自定义器
     */
    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jacksonCustomizer() {
        DateTimeFormatter dateTimeFmt = DateTimeFormatter.ofPattern(DATE_TIME_PATTERN);
        DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern(DATE_PATTERN);
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern(TIME_PATTERN);

        JavaTimeModule module = new JavaTimeModule();
        module.addSerializer(LocalDateTime.class, new LocalDateTimeSerializer(dateTimeFmt));
        module.addDeserializer(LocalDateTime.class, new LocalDateTimeDeserializer(dateTimeFmt));
        module.addSerializer(LocalDate.class, new LocalDateSerializer(dateFmt));
        module.addDeserializer(LocalDate.class, new LocalDateDeserializer(dateFmt));
        module.addSerializer(LocalTime.class, new LocalTimeSerializer(timeFmt));
        module.addDeserializer(LocalTime.class, new LocalTimeDeserializer(timeFmt));

        // 用 modulesToInstall 而不是 modules：
        // modules() 会替换掉 Spring Boot 自动注册的全部模块，
        // modulesToInstall() 只追加，避免覆盖 Boot 的默认模块集合。
        return builder -> builder.modulesToInstall(module);
    }
}