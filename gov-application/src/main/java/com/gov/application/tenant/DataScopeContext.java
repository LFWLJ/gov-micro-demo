package com.gov.application.tenant;

/**
 * 数据范围上下文
 * <p>
 * 基于 ThreadLocal 存放当前请求的用户 ID、部门 ID 与数据权限范围，
 * 供 MyBatis 拦截器在拼装 SQL 时自动追加数据过滤条件。
 * 与 {@link com.gov.common.tenant.TenantContext} 不同：
 * {@code TenantContext} 负责租户级隔离，{@code DataScopeContext} 负责租户内的行级数据权限。
 * </p>
 * <p>
 * 线程内数据由 {@link com.gov.application.tenant.TenantFilter} 在请求进入时写入，
 * 在请求结束时清理，避免线程池复用导致数据串台。
 * </p>
 *
 * @see com.gov.application.tenant.TenantFilter
 */
public class DataScopeContext {

    private static final ThreadLocal<String> USER_ID = new ThreadLocal<>();
    private static final ThreadLocal<Long> DEPT_ID = new ThreadLocal<>();
    private static final ThreadLocal<Integer> DATA_SCOPE = new ThreadLocal<>();

    /**
     * 写入数据范围上下文
     *
     * @param userId    当前用户 ID
     * @param deptId    当前用户所属部门 ID（可为空）
     * @param dataScope 数据权限范围（见 {@code SysRole.dataScope}，1-全部 / 2-本部门 / 3-本部门及以下 / 4-仅本人）
     */
    public static void set(String userId, String deptId, String dataScope) {
        USER_ID.set(userId);
        if (deptId != null && !deptId.isEmpty()) {
            try { DEPT_ID.set(Long.valueOf(deptId)); } catch (NumberFormatException ignore) {}
        }
        if (dataScope != null && !dataScope.isEmpty()) {
            try { DATA_SCOPE.set(Integer.valueOf(dataScope)); } catch (NumberFormatException ignore) {}
        }
    }

    public static String getUserId() { return USER_ID.get(); }
    public static Long getDeptId() { return DEPT_ID.get(); }
    public static Integer getDataScope() { return DATA_SCOPE.get(); }

    public static void clear() {
        USER_ID.remove();
        DEPT_ID.remove();
        DATA_SCOPE.remove();
    }
}