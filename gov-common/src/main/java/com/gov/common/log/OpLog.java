package com.gov.common.log;

import java.lang.annotation.*;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface OpLog {

    /** 模块名，如"事项管理" */
    String module() default "";

    /** 操作描述，如"创建事项" */
    String operation() default "";

    /** 是否记录请求参数 */
    boolean saveParams() default true;

    /** 是否记录返回结果 */
    boolean saveResult() default false;
}