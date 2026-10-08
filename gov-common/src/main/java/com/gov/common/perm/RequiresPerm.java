package com.gov.common.perm;

import java.lang.annotation.*;

/**
 * 接口权限校验注解
 * <p>
 * 标注在 Controller 方法上，由 {@link PermAspect} 在执行前自动校验当前用户是否持有所需权限。
 * </p>
 *
 * <p>使用示例：</p>
 * <pre>{@code
 * // 单一权限要求
 * @RequiresPerm("sys:role:add")
 *
 * // 多权限任一即可（OR 语义）
 * @RequiresPerm({"sys:role:add", "sys:role:edit"})
 * }</pre>
 *
 * @see PermAspect
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequiresPerm {

    /**
     * 所需权限标识数组，多个值之间是 <b>OR</b> 语义（任一匹配即可放行）
     * <p>权限标识定义在菜单表 {@code sys_menu.perms} 字段中，
     * 通常采用 {@code 模块:功能:操作} 的三段式命名，如 {@code sys:role:add}。</p>
     */
    String[] value();
}