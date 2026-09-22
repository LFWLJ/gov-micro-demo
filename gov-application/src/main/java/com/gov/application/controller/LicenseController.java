package com.gov.application.controller;

import com.gov.application.entity.License;
import com.gov.application.entity.LicenseTemplate;
import com.gov.application.service.LicenseService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "电子证照")
@RestController
@RequestMapping("/api/license")
public class LicenseController {

    @Autowired
    private LicenseService licenseService;

    @Operation(summary = "分页查询证照")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "status", required = false) String status) {
        return R.ok(licenseService.page(page, size, keyword, status));
    }

    @Operation(summary = "查询模板列表")
    @GetMapping("/templates")
    public R<List<LicenseTemplate>> templates() {
        return R.ok(licenseService.templates());
    }

    @Operation(summary = "生成证照")
    @PostMapping("/issue")
    @OpLog(module = "电子证照", operation = "生成证照")
    public R<Map<String, Object>> issue(@RequestBody License license) {
        return R.ok("生成成功", licenseService.issue(license));
    }

    @Operation(summary = "证照验真（公开）")
    @GetMapping("/verify/{code}")
    public R<Map<String, Object>> verify(@PathVariable("code") String code) {
        return R.ok(licenseService.verify(code));
    }

    @Operation(summary = "吊销证照")
    @PostMapping("/revoke/{id}")
    @OpLog(module = "电子证照", operation = "吊销证照")
    public R<Void> revoke(@PathVariable("id") Long id) {
        licenseService.revoke(id);
        return R.ok("已吊销", null);
    }
}