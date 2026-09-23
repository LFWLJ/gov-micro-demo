package com.gov.application.service;

import com.gov.application.entity.Application;
import com.gov.application.mapper.ApplicationMapper;
import com.gov.common.exception.BizException;
import com.gov.common.result.ResultCode;
import com.gov.common.tenant.TenantContext;
import org.flowable.engine.HistoryService;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.flowable.engine.history.HistoricProcessInstance;
import org.flowable.engine.runtime.ProcessInstance;
import org.flowable.task.api.Task;
import org.flowable.task.api.history.HistoricTaskInstance;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.gov.application.mq.NotifyMessage;
import com.gov.application.mq.NotifyProducer;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class ProcessBizService {

    private static final Logger log = LoggerFactory.getLogger(ProcessBizService.class);

    private static final String KEY_LEAVE_APPROVAL = "leaveApproval";

    @Autowired
    private RuntimeService runtimeService;

    @Autowired
    private TaskService taskService;

    @Autowired
    private HistoryService historyService;

    @Autowired
    private ApplicationMapper applicationMapper;

    @Autowired
    private ApplicationLogService applicationLogService;

    @Autowired
    private NotifyProducer notifyProducer;

    /**
     * 发起流程
     */
    @Transactional
    public Map<String, Object> startProcess(String businessKey,
                                            String applicant,
                                            Map<String, Object> variables) {
        String tenantId = TenantContext.get();
        if (tenantId == null) {
            throw new BizException("缺少租户标识");
        }
        variables.put("applicant", applicant);
        variables.put("tenantId", tenantId);

        ProcessInstance instance = runtimeService.startProcessInstanceByKeyAndTenantId(
                KEY_LEAVE_APPROVAL,
                businessKey,
                variables,
                tenantId
        );

        Map<String, Object> result = new HashMap<>();
        result.put("processInstanceId", instance.getId());
        result.put("processDefinitionId", instance.getProcessDefinitionId());
        result.put("tenantId", tenantId);
        result.put("businessKey", businessKey);

        // ★ 通知第一审批人
        String deptLeader = (String) variables.get("deptLeader");
        if (deptLeader != null) {
            NotifyMessage msg = NotifyMessage.of(
                    "TASK_CREATED",
                    null,
                    instance.getId(),
                    tenantId,
                    deptLeader,
                    String.format("事项「%s」，申请人：%s", businessKey, applicant)
            );
            notifyProducer.send(msg);
        }
        return result;
    }

    /**
     * 查询当前用户的待办任务
     */
    public List<Map<String, Object>> listTasks(String assignee) {
        String tenantId = TenantContext.get();
        if (tenantId == null) {
            throw new BizException("缺少租户标识");
        }

        List<Task> tasks = taskService.createTaskQuery()
                .taskTenantId(tenantId)
                .taskAssignee(assignee)
                .orderByTaskCreateTime().desc()
                .list();

        return tasks.stream().map(t -> {
            Map<String, Object> m = new HashMap<>();
            m.put("taskId", t.getId());
            m.put("taskName", t.getName());
            m.put("processInstanceId", t.getProcessInstanceId());
            m.put("createTime", com.gov.common.util.DateUtil.format(t.getCreateTime()));  // ★
            m.put("assignee", t.getAssignee());
            return m;
        }).collect(Collectors.toList());
    }

    /**
     * 完成任务（含：完成通知 + 流程结束回调事项状态 + 记录办件流转日志）
     */
    @Transactional(rollbackFor = Exception.class)
    public void completeTask(String taskId, Map<String, Object> variables) {
        String tenantId = TenantContext.get();

        // 1. 校验任务归属
        Task task = taskService.createTaskQuery()
                .taskId(taskId)
                .taskTenantId(tenantId)
                .singleResult();

        if (task == null) {
            throw new BizException(ResultCode.TASK_NOT_FOUND);
        }

        String processInstanceId = task.getProcessInstanceId();
        String assignee = task.getAssignee();

        if (variables == null) {
            variables = new HashMap<>();
        }

        // 2. 完成当前任务
        taskService.complete(taskId, variables);

        // ★ 通知当前处理人任务已完成
        NotifyMessage doneMsg = NotifyMessage.of(
                "TASK_COMPLETED",
                null,
                processInstanceId,
                tenantId,
                assignee,
                String.format("任务「%s」", task.getName())
        );
        notifyProducer.send(doneMsg);

        // 3. 判断流程是否结束
        long remaining = taskService.createTaskQuery()
                .processInstanceId(processInstanceId)
                .taskTenantId(tenantId)
                .count();

        if (remaining == 0) {
            // 流程结束：更新事项状态 + 记录日志
            try {
                HistoricProcessInstance pi = historyService.createHistoricProcessInstanceQuery()
                        .processInstanceId(processInstanceId)
                        .singleResult();

                if (pi != null && pi.getBusinessKey() != null) {
                    Long appId = Long.valueOf(pi.getBusinessKey());
                    Application app = applicationMapper.selectById(appId);
                    if (app != null) {
                        app.setStatus("APPROVED");
                        applicationMapper.updateById(app);

                        // ★ 记录审批通过日志
                        applicationLogService.log(
                                appId,
                                "APPROVE",
                                "审批通过",
                                assignee,
                                "流程审批完成，办件已通过"
                        );
                        // ★ 通知申请人办件通过
                        NotifyMessage approvedMsg = NotifyMessage.of(
                                "PROCESS_APPROVED",
                                appId,
                                processInstanceId,
                                tenantId,
                                app.getApplicant(),
                                String.format("事项「%s」", app.getTitle())
                        );
                        notifyProducer.send(approvedMsg);

                         // ★ 触发评价邀请
                        NotifyMessage inviteMsg = NotifyMessage.of(
                                "EVALUATION_INVITE",
                                appId,
                                processInstanceId,
                                tenantId,
                                app.getApplicant(),
                                String.format("事项「%s」", app.getTitle())
                        );
                        notifyProducer.send(inviteMsg);
                    }
                }
            } catch (Exception e) {
                log.error("流程结束回调失败, processInstanceId={}, 办件状态可能未更新, 需人工补偿", processInstanceId, e);
            }
        }
    }

    /**
     * 查询流程状态
     */
    public Map<String, Object> getProcessStatus(String processInstanceId) {
        String tenantId = TenantContext.get();

        ProcessInstance running = runtimeService.createProcessInstanceQuery()
                .processInstanceId(processInstanceId)
                .singleResult();

        Map<String, Object> result = new HashMap<>();
        if (running != null) {
            if (!tenantId.equals(running.getTenantId())) {
                result.put("finished", true);
                result.put("msg", "流程不存在或无权访问");
                return result;
            }
            result.put("finished", false);
            result.put("currentActivityId", running.getActivityId());
            result.put("businessKey", running.getBusinessKey());
            return result;
        }

        HistoricProcessInstance historic = historyService.createHistoricProcessInstanceQuery()
                .processInstanceId(processInstanceId)
                .singleResult();

        if (historic == null || !tenantId.equals(historic.getTenantId())) {
            result.put("finished", true);
            result.put("msg", "流程不存在或无权访问");
        } else {
            result.put("finished", true);
            result.put("msg", "流程已结束");
            result.put("businessKey", historic.getBusinessKey());
        }
        return result;
    }

    /**
     * 查询流程完整轨迹
     */
    public Map<String, Object> getProcessTrace(String processInstanceId) {
        String tenantId = TenantContext.get();

        HistoricProcessInstance instance = historyService.createHistoricProcessInstanceQuery()
                .processInstanceId(processInstanceId)
                .singleResult();

        if (instance == null) {
            throw new BizException(ResultCode.NOT_FOUND.getCode(), "流程实例不存在");
        }

        if (tenantId != null && !tenantId.equals(instance.getTenantId())) {
            throw new BizException(ResultCode.NOT_FOUND.getCode(), "无权访问该流程");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("processInstanceId", instance.getId());
        result.put("businessKey", instance.getBusinessKey());
        result.put("startTime", com.gov.common.util.DateUtil.format(instance.getStartTime()));   // ★
        result.put("endTime", com.gov.common.util.DateUtil.format(instance.getEndTime()));       // ★
        result.put("finished", instance.getEndTime() != null);
        if (instance.getEndTime() != null) {
            result.put("durationMs", instance.getDurationInMillis());
        }

        List<HistoricTaskInstance> tasks = historyService.createHistoricTaskInstanceQuery()
                .processInstanceId(processInstanceId)
                .orderByHistoricTaskInstanceStartTime().asc()
                .list();

        List<Map<String, Object>> nodes = new ArrayList<>();
        for (HistoricTaskInstance t : tasks) {
            Map<String, Object> node = new HashMap<>();
            node.put("taskId", t.getId());
            node.put("taskName", t.getName());
            node.put("assignee", t.getAssignee());
            node.put("startTime", com.gov.common.util.DateUtil.format(t.getStartTime()));   // ★
            node.put("endTime", com.gov.common.util.DateUtil.format(t.getEndTime()));       // ★
            node.put("durationMs", t.getDurationInMillis());
            node.put("status", t.getEndTime() == null ? "PENDING" : "DONE");
            nodes.add(node);
        }
        result.put("nodes", nodes);

        return result;
    }
}