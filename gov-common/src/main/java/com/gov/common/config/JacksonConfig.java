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

@Configuration
public class JacksonConfig {

    /** 日期时间格式：2026-09-21 14:30:00 */
    private static final String DATE_TIME_PATTERN = "yyyy-MM-dd HH:mm:ss";

    /** 日期格式：2026-09-21 */
    private static final String DATE_PATTERN = "yyyy-MM-dd";

    /** 时间格式：14:30:00 */
    private static final String TIME_PATTERN = "HH:mm:ss";

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

        return builder -> builder.modules(module);
    }
}