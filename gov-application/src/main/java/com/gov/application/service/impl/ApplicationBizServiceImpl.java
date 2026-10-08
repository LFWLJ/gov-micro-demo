package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.Application;
import com.gov.application.mapper.ApplicationMapper;
import com.gov.application.service.ApplicationBizService;
import com.gov.application.service.ApplicationLogService;
import com.gov.application.service.DeptService;
import com.gov.application.tenant.DataScopeContext;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.runtime.ProcessInstance;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 办件业务服务实现
 * <p>
 * 结合 Flowable 工作流引擎实现办件的提交、驳回、撤回等操作。
 * 办件数据通过 MyBatis-Plus 租户拦截器隔离，工作流实例通过 tenantId 字段关联租户。
 * </p>
 *
 * <h3>数据权限</h3>
 * 查询时会根据当前用户的数据权限范围（{@link DataScopeContext}）自动追加过滤条件：
 * <ul>
 *     <li>scope=1（全部数据）：不追加过滤</li>
 *     <li>scope=2（部门及以下）：过滤 deptId 在本部门及子部门内</li>
 *     <li>scope=3（本部门）：过滤 deptId 等于当前部门</li>
 *     <li>scope=4（仅本人）：过滤 createBy 等于当前用户</li>
 * </ul>
 *
 * <h3>状态流转</h3>
 * <pre>
 * DRAFT（草稿）→ PENDING（审批中）→ 通过/驳回/撤回
 * </pre>
 */
@Service
public class ApplicationBizServiceImpl implements ApplicationBizService {

    private static final Logger log = LoggerFactory.getLogger(ApplicationBizServiceImpl.class);

    @Autowired
    private ApplicationMapper applicationMapper;

    @Autowired
    private DeptService deptService;

    @Autowired
    private RuntimeService runtimeService;

    @Autowired
    private ApplicationLogService applicationLogService;

    /**
     * 查询当前租户下的办件列表
     * <p>
     * 根据当前用户的数据权限范围自动过滤数据。
     * </p>
     */
    @Override
    public List<Application> listCurrentTenant() {
        LambdaQueryWrapper<Application> wrapper = new LambdaQueryWrapper<>();
        applyDataScope(wrapper);
        wrapper.orderByAsc(Application::getId);
        return applicationMapper.selectList(wrapper);
    }

    /**
     * 提交办件并启动工作流
     * <p>
     * 流程：写入 application 表 → 启动 Flowable 流程实例（processDefinitionKey=leaveApproval）
     * → 记录操作日志 → 回写 processInstanceId。
     * 所有数据库操作在事务中执行。
     * </p>
     *
     * @return 新建办件的 ID
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long create(String title, String applicant,
                       String deptLeader, String director, String hr, Integer days) {
        String tenantId = TenantContext.get();
        if (tenantId == null) throw new BizException("缺少租户标识");

        Application app = new Application();
        app.setTitle(title);
        app.setApplicant(applicant);
        app.setStatus("PENDING");
        app.setTenantId(tenantId);
        app.setDeptId(DataScopeContext.getDeptId());
        app.setCreateBy(DataScopeContext.getUserId());
        applicationMapper.insert(app);

        Map<String, Object> vars = new HashMap<>();
        vars.put("applicant", applicant);
        vars.put("tenantId", tenantId);
        vars.put("deptLeader", deptLeader);
        vars.put("director", director);
        vars.put("hr", hr);
        vars.put("days", days == null ? 3 : days);

        ProcessInstance instance = runtimeService.createProcessInstanceBuilder()
                .processDefinitionKey("leaveApproval")
                .businessKey(String.valueOf(app.getId()))
                .tenantId(tenantId)
                .variables(vars)
                .start();

        applicationLogService.log(
                app.getId(),
                "SUBMIT",
                "提交申请",
                DataScopeContext.getUserId(),
                "提交办件：" + title
        );

        app.setProcessInstanceId(instance.getId());
        applicationMapper.updateById(app);

        return app.getId();
    }

    /** 驳回申请，状态设为 REJECTED */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reject(Long id, String remark) {
        Application app = applicationMapper.selectById(id);
        if (app == null) throw new BizException("事项不存在");
        app.setStatus("REJECTED");
        applicationMapper.updateById(app);

        applicationLogService.log(id, "REJECT", "驳回申请",
                DataScopeContext.getUserId(), remark == null ? "驳回" : remark);
    }

    /** 撤回申请，状态回退为 DRAFT（草稿） */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void withdraw(Long id, String remark) {
        Application app = applicationMapper.selectById(id);
        if (app == null) throw new BizException("事项不存在");
        app.setStatus("DRAFT");
        applicationMapper.updateById(app);

        applicationLogService.log(id, "WITHDRAW", "撤回申请",
                DataScopeContext.getUserId(), remark == null ? "撤回" : remark);
    }

    @Override
    public Application getById(Long id) {
        return applicationMapper.selectById(id);
    }

    @Override
    public int delete(Long id) {
        return applicationMapper.deleteById(id);
    }

    /**
     * 根据当前用户的数据权限范围追加查询条件
     * <p>
     * scope=1 表示全部数据权限，不追加任何过滤。
     * scope=2 需要查询部门的所有子部门 ID（含自身），这是一个递归的树形查询。
     * </p>
     */
    private void applyDataScope(LambdaQueryWrapper<Application> wrapper) {
        Integer scope = DataScopeContext.getDataScope();
        Long deptId = DataScopeContext.getDeptId();
        String userId = DataScopeContext.getUserId();

        // scope=1 是"全部数据"，合法地不加过滤
        if (scope != null && scope == 1) return;

        // ★ fail-closed：上下文缺失不再等同于"看全部"。
        //   原实现 scope==null 直接 return，而 DataScopeContext 解析 X-Dept-Id 失败时会静默置 null，
        //   于是"请求头丢了/格式不对"就变成越权看到全租户数据。
        if (scope == null) {
            log.warn("数据范围上下文缺失，按最小可见范围处理（不返回任何数据）");
            wrapper.apply("1 = 0");
            return;
        }

        switch (scope) {
            case 2:
                if (deptId == null) { wrapper.apply("1 = 0"); break; }
                List<Long> deptIds = deptService.getSelfAndChildIds(deptId);
                if (deptIds == null || deptIds.isEmpty()) { wrapper.apply("1 = 0"); break; }
                wrapper.in(Application::getDeptId, deptIds);
                break;
            case 3:
                if (deptId == null) { wrapper.apply("1 = 0"); break; }
                wrapper.eq(Application::getDeptId, deptId);
                break;
            case 4:
                if (userId == null || userId.isEmpty()) { wrapper.apply("1 = 0"); break; }
                wrapper.eq(Application::getCreateBy, userId);
                break;
            default:
                // 未知范围值一律按无权限处理
                wrapper.apply("1 = 0");
        }
    }
}