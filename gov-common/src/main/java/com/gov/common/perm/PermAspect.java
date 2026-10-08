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
 * 接口权限校验切面
 * <p>
 * 拦截所有标注 {@link RequiresPerm} 的 Controller 方法，
 * 动态查询当前用户通过角色所拥有的菜单权限集合（{@code perms} 字段），
 * 与接口声明所需的权限做比对，任一匹配即放行。
 * </p>
 *
 * <p>用户 ID 获取的三级兜底策略（避免模块间硬依赖）：</p>
 * <ol>
 *   <li>{@code UserContext}（gov-auth 通过 AuthTenantFilter 注入）— 最可靠</li>
 *   <li>{@code DataScopeContext}（gov-application 的上下文，反射调用避免编译期依赖）— 跨模块兜底</li>
 *   <li>请求头 {@code X-User-Id}（网关统一注入）— 终极兜底</li>
 * </ol>
 *
 * <p>未配置 JdbcTemplate 的模块（如纯网关）会直接跳过权限校验，不影响主流程。</p>
 *
 * @see RequiresPerm
 */
@Aspect
@Component
public class PermAspect {

    private static final Logger log = LoggerFactory.getLogger(PermAspect.class);

    /** 可选注入：纯网关模块没有数据库，不做权限校验 */
    @Autowired(required = false)
    private JdbcTemplate jdbcTemplate;

    /**
     * 环绕通知：执行前校验权限
     *
     * @param pjp         切入点
     * @param requiresPerm 注解元数据（声明所需权限标识）
     * @return 原方法返回值
     */
    @Around("@annotation(requiresPerm)")
    public Object around(ProceedingJoinPoint pjp, RequiresPerm requiresPerm) throws Throwable {
        // 无数据库直接放行（如网关模块）
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

        // 所需权限"任一匹配"即通过
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
     * 三级兜底获取当前用户 ID
     * <p>避免切面强依赖某个特定模块的上下文类。</p>
     *
     * @return 当前用户 ID，三级都取不到则返回 null
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
     * 反射调用外部类的静态无参方法，失败时返回 null
     * <p>用于跨模块获取用户 ID，避免在 gov-common 中硬依赖 gov-application。</p>
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

    /** 从当前请求上下文中读取指定请求头，异常时返回 null */
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

    /**
     * 查询当前用户所拥有的所有权限标识集合
     * <p>
     * 查询链路：用户 → 角色 → 菜单 → 权限。
     * 只取菜单类型为按钮（menu_type='F'）、状态启用、且 perms 字段非空的记录。
     * </p>
     *
     * @param userId 用户 ID
     * @return 权限标识集合，异常时返回空集合并打印 error 日志
     */
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