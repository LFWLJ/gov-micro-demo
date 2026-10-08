package com.gov.common.tenant;

/**
 * 用户上下文（ThreadLocal）
 * <p>
 * 在单个请求线程内同时维护当前操作用户的 {@code userId} 和 {@code tenantId}。
 * 与 {@link TenantContext} 职责不同：
 * <ul>
 *   <li>{@link TenantContext} — 专门服务于 MyBatis-Plus 多租户插件的 SQL 自动拼接</li>
 *   <li>{@link UserContext} — 面向业务层，供 Service / AOP / 工具类统一获取当前登录用户</li>
 * </ul>
 *
 * <p>注入与清理时机同 {@link TenantContext}，由网关 / 登录 Filter 负责 set，
 * 请求结束时 Filter 的 finally 块必须调用 {@link #clear()}。</p>
 *
 * @see TenantContext
 */
public class UserContext {

    /** 当前用户 ID */
    private static final ThreadLocal<String> USER_ID = new ThreadLocal<>();
    /** 当前用户所属租户 ID */
    private static final ThreadLocal<String> TENANT_ID = new ThreadLocal<>();

    /** 设置当前用户 ID */
    public static void setUserId(String userId) { USER_ID.set(userId); }
    /** 获取当前用户 ID，未登录返回 null */
    public static String getUserId() { return USER_ID.get(); }

    /** 设置当前用户所属租户 ID */
    public static void setTenantId(String tenantId) { TENANT_ID.set(tenantId); }
    /** 获取当前用户所属租户 ID */
    public static String getTenantId() { return TENANT_ID.get(); }

    /** 清除当前线程的用户上下文，必须在请求结束时调用 */
    public static void clear() {
        USER_ID.remove();
        TENANT_ID.remove();
    }
}