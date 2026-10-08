package com.gov.common.tenant;

/**
 * 租户上下文（ThreadLocal）
 * <p>
 * 在单个请求线程内传递当前租户标识，MyBatis-Plus 的多租户插件
 * {@link com.gov.common.mybatis.TenantLineHandlerImpl} 从本类取值，
 * 自动为 SQL 追加 {@code WHERE tenant_id = ?} 条件。
 * </p>
 *
 * <p>注入与清理时机：</p>
 * <ul>
 *   <li><b>set</b> — 由网关 / 服务内的 {@code TenantFilter} 或登录 Filter 从请求头
 *       {@code X-Tenant-Id} 提取后注入到当前线程</li>
 *   <li><b>clear</b> — 请求结束时（Filter 的 finally 块）必须调用，否则线程池复用时会串租户</li>
 * </ul>
 *
 * @see com.gov.common.mybatis.TenantLineHandlerImpl
 */
public class TenantContext {

    /** 租户标识 ThreadLocal，每个请求线程独立 */
    private static final ThreadLocal<String> HOLDER = new ThreadLocal<>();

    /** 向当前线程设置租户标识 */
    public static void set(String tenantId) {
        HOLDER.set(tenantId);
    }

    /** 获取当前线程的租户标识，未设置返回 null */
    public static String get() {
        return HOLDER.get();
    }

    /** 清除当前线程的租户标识，必须在请求结束时调用 */
    public static void clear() {
        HOLDER.remove();
    }
}