package com.gov.application.controller;

import com.gov.application.entity.Consult;
import com.gov.application.service.ConsultService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "咨询投诉")
@RestController
@RequestMapping("/api/consult")
public class ConsultController {

    @Autowired
    private ConsultService consultService;

    @Operation(summary = "分页查询")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "type", required = false) String type,
            @RequestParam(value = "status", required = false) String status) {
        return R.ok(consultService.page(page, size, keyword, type, status));
    }

    @Operation(summary = "提交工单")
    @PostMapping
    @OpLog(module = "咨询投诉", operation = "提交工单")
    public R<Long> create(@RequestBody Consult consult) {
        return R.ok("提交成功", consultService.create(consult));
    }

    @Operation(summary = "回复工单")
    @PostMapping("/reply/{id}")
    @OpLog(module = "咨询投诉", operation = "回复工单")
    public R<Void> reply(@PathVariable("id") Long id,
                         @RequestHeader(value = "X-User-Id", required = false) String userId,
                         @RequestBody Map<String, String> body) {
        consultService.reply(id, userId, body.get("reply"));
        return R.ok("回复成功", null);
    }

    @Operation(summary = "关闭工单")
    @PostMapping("/close/{id}")
    @OpLog(module = "咨询投诉", operation = "关闭工单")
    public R<Void> close(@PathVariable("id") Long id) {
        consultService.close(id);
        return R.ok("已关闭", null);
    }

    @Operation(summary = "删除工单")
    @DeleteMapping("/{id}")
    @OpLog(module = "咨询投诉", operation = "删除工单")
    public R<Void> delete(@PathVariable("id") Long id) {
        consultService.delete(id);
        return R.ok("已删除", null);
    }

    @Operation(summary = "统计")
    @GetMapping("/stats")
    public R<Map<String, Object>> stats() {
        return R.ok(consultService.stats());
    }
}