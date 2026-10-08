package com.gov.common.mybatis;

import com.baomidou.mybatisplus.extension.plugins.handler.TenantLineHandler;
import com.gov.common.tenant.TenantContext;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.StringValue;

import java.util.Set;

/**
 * 多租户 SQL 注入处理器
 * <p>
 * 作为 MyBatis-Plus 多租户插件（{@code TenantLineInnerInterceptor}）的核心逻辑提供者，
 * 对每张"参与租户隔离"的表自动追加 {@code WHERE tenant_id = ?} 条件，
 * 实现行级数据隔离，业务代码无需手动拼条件。
 * </p>
 *
 * <p>工作机制：</p>
 * <ol>
 *   <li>插件拦截所有 SQL，调用 {@link #ignoreTable(String)} 判断目标表是否忽略</li>
 *   <li>若不忽略，则调用 {@link #getTenantId()} 取当前线程的租户 ID</li>
 *   <li>在 {@link #getTenantIdColumn()} 指定的列名上自动追加等值条件</li>
 * </ol>
 *
 * <p>忽略的表（{@link #IGNORE_TABLES} / {@link #IGNORE_PREFIXES}）：</p>
 * <ul>
 *   <li>{@code sys_user} — 登录时需跨租户按用户名查询，Service 层已做显式租户校验补偿</li>
 *   <li>{@code sys_tenant} — 平台级租户注册表，加租户过滤会让租户管理失效</li>
 *   <li>{@code sys_menu} / {@code sys_role_menu} / {@code sys_user_role} / {@code sys_role_dept} — 这些表无 tenant_id 列</li>
 *   <li>{@code ACT_*} / {@code act_*} / {@code qrtz_*} — Flowable / Quartz 引擎表</li>
 * </ul>
 *
 * @see MybatisPlusConfig
 * @see com.gov.common.tenant.TenantContext
 */
public class TenantLineHandlerImpl implements TenantLineHandler {

    /**
     * 必须忽略的表（精确匹配）
     * <p>
     * sys_user：登录需"按用户名跨租户查询"，无法统一套用租户条件。
     * 补偿措施：UserServiceImpl 对 sys_user 所有按 id 的读/改/删都做了显式租户校验
     * （见 assertSameTenant / page 的 tenant_id 条件），请勿移除那里的校验。
     * </p>
     * <p>
     * sys_tenant：租户注册表本身是平台级数据，按 tenant_id 过滤会让租户管理失效。
     * </p>
     * <p>
     * sys_menu / sys_role_menu / sys_user_role / sys_role_dept：都没有 tenant_id 列。
     * </p>
     */
    private static final Set<String> IGNORE_TABLES = Set.of(
            "sys_user",
            "sys_tenant",
            "sys_menu",
            "sys_role_menu",
            "sys_user_role",
            "sys_role_dept"
    );

    /** 按前缀忽略：Flowable 流程引擎表（ACT_ / act_）和 Quartz 调度表（qrtz_） */
    private static final Set<String> IGNORE_PREFIXES = Set.of(
            "ACT_",
            "act_",
            "qrtz_"
    );

    /**
     * 获取当前租户 ID 作为 SQL 条件值
     * <p>
     * 由 {@link TenantContext} 在线程中提前注入（Filter 层完成）。
     * 若未注入（如测试环境 / 平台超级管理员场景），返回占位值 {@code __NONE__}，
     * 此时 SQL 条件将匹配不到任何数据，避免误操作。
     * </p>
     *
     * @return 租户 ID 表达式
     */
    @Override
    public Expression getTenantId() {
        String tenantId = TenantContext.get();
        return new StringValue(tenantId == null ? "__NONE__" : tenantId);
    }

    /**
     * 租户隔离列名
     * <p>所有参与多租户的业务表需包含 {@code tenant_id} 字段（VARCHAR 类型）。</p>
     *
     * @return 固定返回 "tenant_id"
     */
    @Override
    public String getTenantIdColumn() {
        return "tenant_id";
    }

    /**
     * 判断指定表是否应忽略多租户过滤
     *
     * @param tableName SQL 中出现的表名
     * @return true = 忽略，不追加 tenant_id 条件
     */
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