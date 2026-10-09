package com.gov.application.controller;

import com.gov.application.dto.ConsultReplyDTO;
import com.gov.application.entity.Consult;
import com.gov.application.service.ConsultService;
import com.gov.common.log.OpLog;
import com.gov.common.perm.RequiresPerm;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 咨询投诉工单 HTTP 接口
 * <p>
 * 市民提交咨询 / 投诉的入口，以及后台回复工单 / 关闭工单 / 删除工单的管理端点。
 * 工单号由 Redis 原子自增生成，同日内不重复。
 * </p>
 */
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
    @RequiresPerm("biz:consult:reply")
    @PostMapping("/reply/{id}")
    @OpLog(module = "咨询投诉", operation = "回复工单")
    public R<Void> reply(@PathVariable("id") Long id,
                         @RequestHeader(value = "X-User-Id", required = false) String userId,
                         @Valid @RequestBody ConsultReplyDTO body) {
        consultService.reply(id, userId, body.getReply());
        return R.ok("回复成功", null);
    }

    @Operation(summary = "关闭工单")
    @RequiresPerm("biz:consult:close")
    @PostMapping("/close/{id}")
    @OpLog(module = "咨询投诉", operation = "关闭工单")
    public R<Void> close(@PathVariable("id") Long id) {
        consultService.close(id);
        return R.ok("已关闭", null);
    }

    @Operation(summary = "删除工单")
    @RequiresPerm("biz:consult:del")
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