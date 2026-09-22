package com.gov.application.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.common.log.OperLog;
import com.gov.common.log.OperLogMapper;
import com.gov.common.result.R;
import com.gov.common.tenant.TenantContext;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "操作日志")
@RestController
@RequestMapping("/api/operlog")
public class OperLogController {

    @Autowired
    private OperLogMapper operLogMapper;

    @Operation(summary = "分页查询操作日志")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "module", required = false) String module,
            @RequestParam(value = "operation", required = false) String operation,
            @RequestParam(value = "userId", required = false) String userId,
            @RequestParam(value = "result", required = false) Integer result) {

        // 确保有租户上下文
        if (TenantContext.get() == null) {
            return R.fail(403, "缺少租户标识");
        }

        LambdaQueryWrapper<OperLog> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(module)) {
            wrapper.like(OperLog::getModule, module);
        }
        if (StringUtils.hasText(operation)) {
            wrapper.like(OperLog::getOperation, operation);
        }
        if (StringUtils.hasText(userId)) {
            wrapper.eq(OperLog::getUserId, userId);
        }
        if (result != null) {
            wrapper.eq(OperLog::getResult, result);
        }
        wrapper.orderByDesc(OperLog::getId);

        Page<OperLog> p = new Page<>(page, size);
        Page<OperLog> resultPage = operLogMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", resultPage.getTotal());
        data.put("records", resultPage.getRecords());
        data.put("current", resultPage.getCurrent());
        data.put("size", resultPage.getSize());
        return R.ok(data);
    }
}