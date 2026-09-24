package com.gov.application.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.gov.application.dto.BatchAddDTO;
import com.gov.application.dto.SensitiveWordQueryDTO;
import com.gov.application.entity.SensitiveWord;
import com.gov.application.service.SensitiveWordService;
import com.gov.common.perm.RequiresPerm;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

@Tag(name = "敏感词管理")
@RestController
@RequestMapping("/api/sensitive")
public class SensitiveWordController {

    @Resource
    private SensitiveWordService sensitiveWordService;

    @Operation(summary = "分页查询")
    @PostMapping("/page")
    public R<IPage<SensitiveWord>> page(@RequestBody SensitiveWordQueryDTO query) {
        return R.ok(sensitiveWordService.pageWords(query));
    }

    @Operation(summary = "新增")
    @RequiresPerm("sys:sensitive:add")
    @PostMapping
    public R<Void> add(@RequestBody SensitiveWord word) {
        sensitiveWordService.addWord(word);
        return R.ok("新增成功", null);
    }

    @Operation(summary = "修改")
    @RequiresPerm("sys:sensitive:edit")
    @PutMapping
    public R<Void> update(@RequestBody SensitiveWord word) {
        sensitiveWordService.updateWord(word);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除")
    @RequiresPerm("sys:sensitive:del")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable("id") Long id) {
        sensitiveWordService.deleteWord(id);
        return R.ok("删除成功", null);
    }

    @Operation(summary = "批量导入")
    @RequiresPerm("sys:sensitive:add")
    @PostMapping("/batch")
    public R<Integer> batchAdd(@RequestBody BatchAddDTO dto) {
        int count = sensitiveWordService.batchAdd(dto);
        return R.ok("成功导入 " + count + " 条", count);
    }
}