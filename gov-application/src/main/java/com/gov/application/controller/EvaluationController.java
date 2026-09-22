package com.gov.application.controller;

import com.gov.application.entity.Evaluation;
import com.gov.application.service.EvaluationService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

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
    @PostMapping("/rectify/{evaluationId}")
    @OpLog(module = "好差评", operation = "差评整改")
    public R<Void> rectify(@PathVariable("evaluationId") Long evaluationId,
                           @RequestBody Map<String, String> body) {
        evaluationService.rectify(evaluationId, body.get("content"));
        return R.ok("整改完成", null);
    }

    @Operation(summary = "评价统计")
    @GetMapping("/stats")
    public R<Map<String, Object>> stats() {
        return R.ok(evaluationService.stats());
    }
}