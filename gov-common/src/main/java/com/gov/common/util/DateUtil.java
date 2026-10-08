package com.gov.common.util;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 日期格式化工具类
 * <p>
 * 提供统一的 {@code yyyy-MM-dd HH:mm:ss} 格式输出。
 * 注意：{@link SimpleDateFormat} 是线程不安全的，这里作为工具类的短生命周期调用，
 * 每次 {@code format} 新建实例，避免并发问题。
 * </p>
 */
public class DateUtil {

    /** 默认格式：yyyy-MM-dd HH:mm:ss */
    private static final String PATTERN = "yyyy-MM-dd HH:mm:ss";

    /**
     * 将 {@link Date} 格式化为字符串
     *
     * @param date 日期对象
     * @return 格式化字符串，或 null（入参为 null 时）
     */
    public static String format(Date date) {
        if (date == null) return null;
        return new SimpleDateFormat(PATTERN).format(date);
    }

    /**
     * 通用格式化入口：将任意对象尝试格式化为日期字符串
     * <p>
     * 入参为 {@link Date} 时走标准格式化；其他类型直接 {@code toString} 返回。
     * </p>
     *
     * @param date 任意对象
     * @return 格式化字符串，或 null（入参为 null 时）
     */
    public static String format(Object date) {
        if (date == null) return null;
        if (date instanceof Date) {
            return format((Date) date);
        }
        return date.toString();
    }
}