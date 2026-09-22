package com.gov.common.mybatis;

import com.baomidou.mybatisplus.extension.plugins.handler.TenantLineHandler;
import com.gov.common.tenant.TenantContext;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.StringValue;

public class TenantLineHandlerImpl implements TenantLineHandler {

    /** 不需要加租户条件的表（全局字典等） */
    private static final java.util.Set<String> IGNORE_TABLES = java.util.Set.of(
            "sys_user",
            "sys_tenant",
            "sys_dict",
            "sys_config"
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