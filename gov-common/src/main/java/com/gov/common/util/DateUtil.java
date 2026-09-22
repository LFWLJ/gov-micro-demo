package com.gov.common.util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class DateUtil {

    private static final String PATTERN = "yyyy-MM-dd HH:mm:ss";

    public static String format(Date date) {
        if (date == null) return null;
        return new SimpleDateFormat(PATTERN).format(date);
    }

    public static String format(Object date) {
        if (date == null) return null;
        if (date instanceof Date) {
            return format((Date) date);
        }
        return date.toString();
    }
}