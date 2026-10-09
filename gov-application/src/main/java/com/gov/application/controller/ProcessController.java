package com.gov.application.controller;

import com.gov.application.dto.ProcessCompleteDTO;
import com.gov.application.dto.ProcessStartDTO;
import com.gov.application.service.ProcessBizService;
import com.gov.common.log.OpLog;
import com.gov.common.perm.RequiresPerm;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 审批流程 HTTP 接口（基于 Flowable）
 * <p>
 * 直接操作工作流引擎的端点：发起流程 / 查询待办 / 完成任务 / 查流程状态 / 查流程轨迹。
 * 业务上更推荐通过 {@link ApplicationController} 的办件端点间接操作，本 Controller 暴露给
 * 需要绕过办件层直接操作流程的场景（如纯审批任务）。
 * </p>
 */
@Tag(name = "审批流程")
@RestController
@RequestMapping("/api/process")
public class ProcessController {

    @Autowired
    private ProcessBizService processBizService;

    @Operation(summary = "发起流程")
    @RequiresPerm("biz:process:start")
    @PostMapping("/start")
    @OpLog(module = "审批流程", operation = "发起流程")
    public R<Map<String, Object>> start(@Valid @RequestBody ProcessStartDTO body) {
        Map<String, Object> data = processBizService.startProcess(
                body.getBusinessKey(), body.getApplicant(), body.toVariables());
        return R.ok("流程发起成功", data);
    }

    @Operation(summary = "查询待办")
    @GetMapping("/tasks")
    public R<Map<String, Object>> tasks(
            @Parameter(description = "处理人") @RequestParam String assignee) {
        List<Map<String, Object>> list = processBizService.listTasks(assignee);
        Map<String, Object> data = new HashMap<>();
        data.put("count", list.size());
        data.put("items", list);
        return R.ok(data);
    }

    @Operation(summary = "完成任务")
    @RequiresPerm("biz:process:complete")
    @PostMapping("/complete/{taskId}")
    @OpLog(module = "审批流程", operation = "完成任务")
    public R<Void> complete(
            @Parameter(description = "任务ID") @PathVariable String taskId,
            @RequestBody(required = false) ProcessCompleteDTO vars) {
        processBizService.completeTask(taskId,
                vars == null ? new HashMap<>() : vars.toVariables());
        return R.ok("任务已完成", null);
    }

    @Operation(summary = "查询流程状态")
    @GetMapping("/status/{processInstanceId}")
    public R<Map<String, Object>> status(
            @Parameter(description = "流程实例ID") @PathVariable String processInstanceId) {
        Map<String, Object> data = processBizService.getProcessStatus(processInstanceId);
        return R.ok(data);
    }
    @Operation(summary = "查询流程轨迹")
    @GetMapping("/trace/{processInstanceId}")
    public R<Map<String, Object>> trace(@PathVariable("processInstanceId") String processInstanceId) {
        return R.ok(processBizService.getProcessTrace(processInstanceId));
    }
}