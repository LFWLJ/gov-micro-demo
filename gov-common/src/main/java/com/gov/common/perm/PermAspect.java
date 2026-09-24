package com.gov.common.perm;

import com.gov.common.exception.BizException;
import com.gov.common.tenant.UserContext;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 权限校验切面
 * 用户 ID 获取优先级：
 *   1. gov-common UserContext（gov-auth 通过 AuthTenantFilter 注入）
 *   2. gov-application DataScopeContext（反射调用，避免硬依赖）
 *   3. 请求头 X-User-Id（兜底，任何模块都可用）
 */
@Aspect
@Component
public class PermAspect {

    private static final Logger log = LoggerFactory.getLogger(PermAspect.class);

    @Autowired(required = false)
    private JdbcTemplate jdbcTemplate;

    @Around("@annotation(requiresPerm)")
    public Object around(ProceedingJoinPoint pjp, RequiresPerm requiresPerm) throws Throwable {
        if (jdbcTemplate == null) {
            return pjp.proceed();
        }

        String userId = currentUserId();
        if (userId == null || userId.isEmpty()) {
            throw new BizException("未登录");
        }

        Set<String> perms = loadPerms(userId);
        if (perms.isEmpty()) {
            throw new BizException("无任何权限");
        }

        boolean ok = false;
        for (String p : requiresPerm.value()) {
            if (perms.contains(p)) {
                ok = true;
                break;
            }
        }
        if (!ok) {
            log.warn("权限校验不通过: userId={}, required={}", userId, String.join(",", requiresPerm.value()));
            throw new BizException("无权限操作");
        }

        return pjp.proceed();
    }

    /**
     * 多级兜底获取当前用户ID
     */
    private String currentUserId() {
        // 1) gov-common 的 UserContext（gov-auth 已通过 AuthTenantFilter 注入）
        String uid = UserContext.getUserId();
        if (isNotEmpty(uid)) return uid;

        // 2) gov-application 的 DataScopeContext（反射，避免编译期硬依赖）
        uid = tryInvokeStatic("com.gov.application.tenant.DataScopeContext", "getUserId");
        if (isNotEmpty(uid)) return uid;

        // 3) 兜底：直接读请求头
        return getHeader("X-User-Id");
    }

    private boolean isNotEmpty(String s) {
        return s != null && !s.isEmpty();
    }

    /**
     * 反射调用静态无参方法
     */
    private String tryInvokeStatic(String className, String methodName) {
        try {
            Class<?> clazz = Class.forName(className);
            Object v = clazz.getMethod(methodName).invoke(null);
            return v == null ? null : String.valueOf(v);
        } catch (Throwable e) {
            return null;
        }
    }

    private String getHeader(String name) {
        try {
            ServletRequestAttributes attrs =
                    (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
            if (attrs == null) return null;
            HttpServletRequest req = attrs.getRequest();
            return req.getHeader(name);
        } catch (Throwable e) {
            return null;
        }
    }

    private Set<String> loadPerms(String userId) {
        String sql =
                "SELECT DISTINCT m.perms " +
                        "FROM sys_user_role ur " +
                        "JOIN sys_role_menu rm ON rm.role_id = ur.role_id " +
                        "JOIN sys_menu m ON m.id = rm.menu_id " +
                        "WHERE ur.user_id = ? " +
                        "  AND m.menu_type = 'F' " +
                        "  AND m.status = 1 " +
                        "  AND m.perms IS NOT NULL " +
                        "  AND m.perms <> ''";

        try {
            List<String> list = jdbcTemplate.queryForList(sql, String.class, userId);
            return new HashSet<>(list);
        } catch (Exception e) {
            log.error("查询用户权限失败: userId={}", userId, e);
            return new HashSet<>();
        }
    }
}