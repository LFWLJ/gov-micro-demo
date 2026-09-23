package com.gov.common.mybatis;

import com.baomidou.mybatisplus.extension.plugins.handler.TenantLineHandler;
import com.gov.common.tenant.TenantContext;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.StringValue;

public class TenantLineHandlerImpl implements TenantLineHandler {


    private static final java.util.Set<String> IGNORE_TABLES = java.util.Set.of(
            "sys_user",
            "sys_tenant",
            "sys_dict",
            "sys_dict_type",
            "sys_config",
            "sys_login_log",
            "ACT_GE_BYTEARRAY"
            // ... 其他 ACT_ 表

    );

    @Override
    public Expression getTenantId() {
        String tenantId = TenantContext.get();
        // 如果租户为空（比如定时任务、系统内部调用），返回一个不存在的值
        return new StringValue(tenantId == null ? "__NONE__" : tenantId);
    }

    @Override
    public String getTenantIdColumn() {
        return "tenant_id";
    }

    @Override
    public boolean ignoreTable(String tableName) {
        return IGNORE_TABLES.contains(tableName);
    }
}