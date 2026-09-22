package com.gov.application.controller;

import com.gov.application.entity.SysConfig;
import com.gov.application.service.ConfigService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "系统配置")
@RestController
@RequestMapping("/api/config")
public class ConfigController {

    @Autowired
    private ConfigService configService;

    @Operation(summary = "配置列表")
    @GetMapping("/list")
    public R<List<SysConfig>> list(
            @RequestParam(value = "keyword", required = false) String keyword) {
        return R.ok(configService.list(keyword));
    }

    @Operation(summary = "按 key 取值")
    @GetMapping("/value/{key}")
    public R<String> value(@PathVariable("key") String key) {
        return R.ok(configService.getValue(key));
    }

    @Operation(summary = "新增配置")
    @PostMapping
    @OpLog(module = "系统配置", operation = "新增配置")
    public R<Long> create(@RequestBody SysConfig config) {
        return R.ok("新增成功", configService.create(config));
    }

    @Operation(summary = "修改配置")
    @PutMapping
    @OpLog(module = "系统配置", operation = "修改配置")
    public R<Void> update(@RequestBody SysConfig config) {
        configService.update(config);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除配置")
    @DeleteMapping("/{id}")
    @OpLog(module = "系统配置", operation = "删除配置")
    public R<Void> delete(@PathVariable("id") Long id) {
        configService.delete(id);
        return R.ok("删除成功", null);
    }
}