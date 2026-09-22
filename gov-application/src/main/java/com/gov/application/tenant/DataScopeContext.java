package com.gov.application.tenant;

public class DataScopeContext {

    private static final ThreadLocal<String> USER_ID = new ThreadLocal<>();
    private static final ThreadLocal<Long> DEPT_ID = new ThreadLocal<>();
    private static final ThreadLocal<Integer> DATA_SCOPE = new ThreadLocal<>();

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