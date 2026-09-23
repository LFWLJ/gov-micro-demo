package com.gov.application.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.Application;
import com.gov.application.entity.Notify;
import com.gov.application.mapper.ApplicationMapper;
import com.gov.application.mapper.NotifyMapper;
import com.gov.common.result.R;
import com.gov.common.tenant.TenantContext;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.flowable.engine.TaskService;
import org.flowable.task.api.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Tag(name = "工作台")
@RestController
@RequestMapping("/api/workspace")
public class WorkspaceController {

    @Autowired
    private TaskService taskService;

    @Autowired
    private ApplicationMapper applicationMapper;

    @Autowired
    private NotifyMapper notifyMapper;

    @Operation(summary = "工作台汇总")
    @GetMapping("/summary")
    public R<Map<String, Object>> summary(
            @RequestParam("assignee") String assignee,
            @RequestParam(value = "applicant", required = false) String applicant,
            @RequestParam(value = "receiver", required = false) String receiver) {

        String tenantId = TenantContext.get();
        Map<String, Object> data = new HashMap<>();

        // 1. 待办任务数
        Long pendingTaskCount = taskService.createTaskQuery()
                .taskTenantId(tenantId)
                .taskAssignee(assignee)
                .count();
        data.put("pendingTaskCount", pendingTaskCount);

        // 2. 待办任务列表（最近 5 条）
        List<Task> tasks = taskService.createTaskQuery()
                .taskTenantId(tenantId)
                .taskAssignee(assignee)
                .orderByTaskCreateTime().desc()
                .listPage(0, 5);

        List<Map<String, Object>> taskList = tasks.stream().map(t -> {
            Map<String, Object> m = new HashMap<>();
            m.put("taskId", t.getId());
            m.put("taskName", t.getName());
            m.put("processInstanceId", t.getProcessInstanceId());
            m.put("createTime", com.gov.common.util.DateUtil.format(t.getCreateTime()));
            m.put("assignee", t.getAssignee());
            return m;
        }).collect(Collectors.toList());
        data.put("pendingTasks", taskList);

        // 3. 我的申请（按申请人查询）
        if (applicant != null && !applicant.isEmpty()) {
            LambdaQueryWrapper<Application> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(Application::getApplicant, applicant);
            wrapper.orderByDesc(Application::getId);
            List<Application> apps = applicationMapper.selectList(wrapper);

            data.put("myApplicationCount", apps.size());

            List<Map<String, Object>> appList = new ArrayList<>();
            int limit = Math.min(5, apps.size());
            for (int i = 0; i < limit; i++) {
                Application app = apps.get(i);
                Map<String, Object> m = new HashMap<>();
                m.put("id", app.getId());
                m.put("title", app.getTitle());
                m.put("status", app.getStatus());
                m.put("createTime", app.getCreateTime());
                appList.add(m);
            }
            data.put("myApplications", appList);
        } else {
            data.put("myApplicationCount", 0);
            data.put("myApplications", new ArrayList<>());
        }

        // 4. 未读消息数
        if (receiver != null && !receiver.isEmpty()) {
            Long unreadCount = notifyMapper.selectCount(
                    new LambdaQueryWrapper<Notify>()
                            .eq(Notify::getReceiver, receiver)
                            .eq(Notify::getIsRead, 0));
            data.put("unreadCount", unreadCount);

            // 最近 3 条消息
            List<Notify> notifies = notifyMapper.selectList(
                    new LambdaQueryWrapper<Notify>()
                            .eq(Notify::getReceiver, receiver)
                            .orderByDesc(Notify::getId)
                            .last("LIMIT 3"));
            List<Map<String, Object>> notifyList = notifies.stream().map(n -> {
                Map<String, Object> m = new HashMap<>();
                m.put("id", n.getId());
                m.put("title", n.getTitle());
                m.put("content", n.getContent());
                m.put("type", n.getType());
                m.put("isRead", n.getIsRead());
                m.put("createTime", n.getCreateTime());
                return m;
            }).collect(Collectors.toList());
            data.put("recentNotifies", notifyList);
        } else {
            data.put("unreadCount", 0);
            data.put("recentNotifies", new ArrayList<>());
        }

        return R.ok(data);
    }
}