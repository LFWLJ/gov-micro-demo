package com.gov.common.perm;

import java.lang.annotation.*;

/**
 * 接口权限校验注解
 * 用法：
 *   @RequiresPerm("sys:role:add")
 *   @RequiresPerm({"sys:role:add", "sys:role:edit"})   // 任一即可
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface RequiresPerm {

    /** 需要的权限标识，多个满足任一即可 */
    String[] value();
}