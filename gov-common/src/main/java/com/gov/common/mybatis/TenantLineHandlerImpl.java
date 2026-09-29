package com.gov.common.mybatis;

import com.baomidou.mybatisplus.extension.plugins.handler.TenantLineHandler;
import com.gov.common.tenant.TenantContext;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.StringValue;

import java.util.Set;

public class TenantLineHandlerImpl implements TenantLineHandler {

    private static final Set<String> IGNORE_TABLES = Set.of(
            // ↓ 登录需"按用户名跨租户查询"，无法统一套用租户条件。
            //   补偿措施：UserServiceImpl 对 sys_user 所有按 id 的读/改/删都做了显式租户校验
            //   （见 assertSameTenant / page 的 tenant_id 条件），请勿移除那里的校验。
            "sys_user",
            // ↓ 租户注册表本身是平台级数据，按 tenant_id 过滤会让租户管理失效
            "sys_tenant",
            // ↓ 角色/菜单相关的表都没有 tenant_id 列，必须忽略
            "sys_menu",
            "sys_role_menu",
            "sys_user_role",
            "sys_role_dept"
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