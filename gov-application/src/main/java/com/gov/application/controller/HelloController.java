package com.gov.application.controller;

import com.gov.api.feign.FileFeignClient;
import com.gov.application.entity.Application;
import com.gov.application.service.ApplicationBizService;
import com.gov.application.service.ProcessBizService;
import com.gov.common.tenant.TenantContext;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.gov.application.entity.ApplicationLog;
import com.gov.application.service.ApplicationLogService;


import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "事项管理")
@RestController
@RequestMapping("/api/application")
public class HelloController {

    @Autowired
    private ApplicationBizService bizService;

    @Autowired
    private ProcessBizService processBizService;

    @Autowired
    private ApplicationLogService applicationLogService;

    @Operation(summary = "探活")
    @GetMapping("/hello")
    public R<Map<String, Object>> hello() {
        Map<String, Object> data = new HashMap<>();
        data.put("service", "gov-application");
        data.put("time", LocalDateTime.now().toString());
        return R.ok("政务业务服务运行正常", data);
    }

    @Operation(summary = "当前用户上下文")
    @GetMapping("/whoami")
    public R<Map<String, Object>> whoami(
            @RequestHeader(value = "X-User-Id", required = false) String userId,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId,
            @RequestHeader(value = "X-Roles", required = false) String roles) {
        Map<String, Object> data = new HashMap<>();
        data.put("userId", userId);
        data.put("tenantId", tenantId);
        data.put("roles", roles);
        return R.ok(data);
    }

    @Operation(summary = "查询事项列表")
    @GetMapping("/list")
    public R<Map<String, Object>> list() {
        List<Application> list = bizService.listCurrentTenant();
        Map<String, Object> data = new HashMap<>();
        data.put("tenantId", TenantContext.get());
        data.put("count", list.size());
        data.put("items", list);
        return R.ok(data);
    }

    @Operation(summary = "创建事项（自动发起流程）")
    @PostMapping("/create")
    @OpLog(module = "事项管理", operation = "创建事项")
    public R<Long> create(@RequestBody Map<String, Object> body) {
        String title = (String) body.get("title");
        String applicant = (String) body.get("applicant");
        String deptLeader = (String) body.getOrDefault("deptLeader", "LiSi");
        String director = (String) body.getOrDefault("director", "WangWu");
        String hr = (String) body.getOrDefault("hr", "ZhaoLiu");
        Integer days = body.get("days") == null ? 3 : Integer.valueOf(body.get("days").toString());

        Long id = bizService.create(title, applicant, deptLeader, director, hr, days);
        return R.ok("创建成功", id);
    }

    @Operation(summary = "按ID查询")
    @GetMapping("/{id}")
    public R<Application> getById(@PathVariable Long id) {
        Application app = bizService.getById(id);
        if (app == null) {
            return R.fail(404, "事项不存在或无权访问");
        }
        return R.ok(app);
    }

    @Autowired
    private FileFeignClient fileFeignClient;

    @Operation(summary = "获取文件下载URL（Feign 调用 gov-file）")
    @GetMapping("/file-url")
    public R<Map<String, Object>> fileUrl(@RequestParam String objectName) {
        R<Map<String, Object>> fileResult = fileFeignClient.getUrl(objectName);
        if (fileResult.getCode() != 200) {
            return R.fail(fileResult.getCode(), fileResult.getMsg());
        }
        return R.ok(fileResult.getData());
    }

    @Operation(summary = "Feign 透传上下文测试")
    @GetMapping("/feign-context")
    public R<Map<String, Object>> feignContext() {
        // 调 gov-file 的 /my-count 接口，看能不能拿到当前用户
        R<Map<String, Object>> result = fileFeignClient.getUrl("test");
        Map<String, Object> data = new HashMap<>();
        data.put("tenantId", TenantContext.get());
        data.put("feignResult", result);
        return R.ok(data);
    }

    @Operation(summary = "查看事项流程轨迹")
    @GetMapping("/{id}/trace")
    public R<Map<String, Object>> trace(@PathVariable("id") Long id) {
        Application app = bizService.getById(id);
        if (app == null || app.getProcessInstanceId() == null) {
            return R.fail(404, "该事项没有关联流程");
        }
        return R.ok(processBizService.getProcessTrace(app.getProcessInstanceId()));
    }
    @Operation(summary = "查看事项流转日志")
    @GetMapping("/{id}/logs")
    public R<List<ApplicationLog>> logs(@PathVariable("id") Long id) {
        return R.ok(applicationLogService.listByApplication(id));
    }

    @Operation(summary = "驳回事项")
    @PostMapping("/{id}/reject")
    @OpLog(module = "事项管理", operation = "驳回事项")
    public R<Void> reject(@PathVariable("id") Long id,
                          @RequestBody(required = false) Map<String, String> body) {
        bizService.reject(id, body == null ? null : body.get("remark"));
        return R.ok("已驳回", null);
    }

    @Operation(summary = "撤回事项")
    @PostMapping("/{id}/withdraw")
    @OpLog(module = "事项管理", operation = "撤回事项")
    public R<Void> withdraw(@PathVariable("id") Long id,
                            @RequestBody(required = false) Map<String, String> body) {
        bizService.withdraw(id, body == null ? null : body.get("remark"));
        return R.ok("已撤回", null);
    }
}