package com.gov.application.controller;

import com.gov.application.dto.RectifyDTO;
import com.gov.application.entity.Evaluation;
import com.gov.application.service.EvaluationService;
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
 * 好差评 HTTP 接口
 * <p>
 * 1~5 星评价提交 + 差评整改闭环。系统自动把 score≤2 的标记为差评，
 * 差评需在整改端点提交整改内容后才能进入 RECTIFIED 状态。
 * </p>
 */
@Tag(name = "好差评")
@RestController
@RequestMapping("/api/evaluation")
public class EvaluationController {

    @Autowired
    private EvaluationService evaluationService;

    @Operation(summary = "分页查询评价")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "score", required = false) Integer score,
            @RequestParam(value = "isBad", required = false) Integer isBad,
            @RequestParam(value = "rectifyStatus", required = false) String rectifyStatus) {
        return R.ok(evaluationService.page(page, size, score, isBad, rectifyStatus));
    }

    @Operation(summary = "提交评价")
    @PostMapping
    @OpLog(module = "好差评", operation = "提交评价")
    public R<Long> submit(@RequestBody Evaluation eval) {
        return R.ok("评价成功", evaluationService.submit(eval));
    }

    @Operation(summary = "提交整改")
    @RequiresPerm("biz:evaluation:rectify")
    @PostMapping("/rectify/{evaluationId}")
    @OpLog(module = "好差评", operation = "差评整改")
    public R<Void> rectify(@PathVariable("evaluationId") Long evaluationId,
                           @Valid @RequestBody RectifyDTO body) {
        evaluationService.rectify(evaluationId, body.getContent());
        return R.ok("整改完成", null);
    }

    @Operation(summary = "评价统计")
    @GetMapping("/stats")
    public R<Map<String, Object>> stats() {
        return R.ok(evaluationService.stats());
    }
}