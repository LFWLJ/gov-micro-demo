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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ApplicationBizServiceImpl implements ApplicationBizService {

    @Autowired
    private ApplicationMapper applicationMapper;

    @Autowired
    private DeptService deptService;

    @Autowired
    private RuntimeService runtimeService;

    @Autowired
    private ApplicationLogService applicationLogService;

    @Override
    public List<Application> listCurrentTenant() {
        LambdaQueryWrapper<Application> wrapper = new LambdaQueryWrapper<>();
        applyDataScope(wrapper);
        wrapper.orderByAsc(Application::getId);
        return applicationMapper.selectList(wrapper);
    }

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

    private void applyDataScope(LambdaQueryWrapper<Application> wrapper) {
        Integer scope = DataScopeContext.getDataScope();
        Long deptId = DataScopeContext.getDeptId();
        String userId = DataScopeContext.getUserId();

        if (scope == null || scope == 1) return;

        switch (scope) {
            case 2:
                if (deptId != null) {
                    List<Long> deptIds = deptService.getSelfAndChildIds(deptId);
                    wrapper.in(Application::getDeptId, deptIds);
                }
                break;
            case 3:
                if (deptId != null) {
                    wrapper.eq(Application::getDeptId, deptId);
                }
                break;
            case 4:
                if (userId != null) {
                    wrapper.eq(Application::getCreateBy, userId);
                }
                break;
        }
    }
}