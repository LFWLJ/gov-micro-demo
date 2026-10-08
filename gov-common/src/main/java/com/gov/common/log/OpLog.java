package com.gov.common.log;

import java.lang.annotation.*;

/**
 * 操作日志注解
 * <p>
 * 标注在 Controller 的公开方法上，由 {@link OperLogAspect} 切面拦截，
 * 自动将该接口的模块名、操作描述、请求参数、耗时、结果等信息持久化到
 * {@code sys_oper_log} 表。
 * </p>
 *
 * <p>使用示例：</p>
 * <pre>{@code
 * @OpLog(module = "角色管理", operation = "新增角色", saveParams = true)
 * @PostMapping("/role/add")
 * public R<Void> add(@RequestBody SysRole role) { ... }
 * }</pre>
 *
 * @see OperLogAspect
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface OpLog {

    /** 业务模块名，如"事项管理" */
    String module() default "";

    /** 操作描述，如"创建事项" */
    String operation() default "";

    /** 是否记录请求参数，默认 true。敏感字段会自动脱敏 */
    boolean saveParams() default true;

    /** 是否记录返回结果，默认 false（避免返回体过大） */
    boolean saveResult() default false;
}