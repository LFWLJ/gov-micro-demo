package com.gov.application.controller;

import com.gov.application.service.ProcessBizService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "审批流程")
@RestController
@RequestMapping("/api/process")
public class ProcessController {

    @Autowired
    private ProcessBizService processBizService;

    @Operation(summary = "发起流程")
    @PostMapping("/start")
    @OpLog(module = "审批流程", operation = "发起流程")
    public R<Map<String, Object>> start(@RequestBody Map<String, Object> body) {
        String businessKey = (String) body.remove("businessKey");
        String applicant = (String) body.remove("applicant");
        Map<String, Object> data = processBizService.startProcess(
                businessKey, applicant, new HashMap<>(body));
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
    @PostMapping("/complete/{taskId}")
    @OpLog(module = "审批流程", operation = "完成任务")
    public R<Void> complete(
            @Parameter(description = "任务ID") @PathVariable String taskId,
            @RequestBody(required = false) Map<String, Object> vars) {
        processBizService.completeTask(taskId, vars == null ? new HashMap<>() : vars);
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