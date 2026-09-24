package com.gov.common.mybatis;

import com.baomidou.mybatisplus.extension.plugins.handler.TenantLineHandler;
import com.gov.common.tenant.TenantContext;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.StringValue;

import java.util.Set;

public class TenantLineHandlerImpl implements TenantLineHandler {

    private static final Set<String> IGNORE_TABLES = Set.of(
            "sys_user",
            "sys_tenant",
            "sys_dict",
            "sys_dict_type",
            "sys_config",
            "sys_login_log",
            "sys_oper_log",
            "t_file_info",
            "t_file",
            // ↓ 角色/菜单相关的表都没有 tenant_id 列，必须忽略
            "sys_menu",
            "sys_role_menu",
            "sys_user_role",
            "sys_role_dept",
            // ↓ 附件表也没有 tenant_id
            "t_attachment"
    );

    private static final Set<String> IGNORE_PREFIXES = Set.of(
            "ACT_",
            "act_",
            "qrtz_"
    );

    @Override
    public Expression getTenantId() {
        String tenantId = TenantContext.get();
        return new StringValue(tenantId == null ? "__NONE__" : tenantId);
    }

    @Override
    public String getTenantIdColumn() {
        return "tenant_id";
    }

    @Override
    public boolean ignoreTable(String tableName) {
        if (IGNORE_TABLES.contains(tableName)) {
            return true;
        }
        for (String prefix : IGNORE_PREFIXES) {
            if (tableName.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }
}