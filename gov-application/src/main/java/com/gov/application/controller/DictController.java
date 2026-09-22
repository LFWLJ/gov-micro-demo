package com.gov.application.controller;

import com.gov.application.entity.SysDict;
import com.gov.application.service.DictService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.gov.application.entity.SysDictType;

import java.util.List;
import java.util.Map;

@Tag(name = "数据字典")
@RestController
@RequestMapping("/api/dict")
public class DictController {

    @Autowired
    private DictService dictService;

    @Operation(summary = "查询所有字典类型")
    @GetMapping("/types")
    public R<List<Map<String, Object>>> types() {
        return R.ok(dictService.listTypes());
    }

    @Operation(summary = "按类型查询字典项")
    @GetMapping("/data/{dictType}")
    public R<List<SysDict>> data(@PathVariable("dictType") String dictType) {
        return R.ok(dictService.listByTypeCached(dictType));
    }

    @Operation(summary = "新增字典")
    @PostMapping
    @OpLog(module = "数据字典", operation = "新增字典")
    public R<Long> create(@RequestBody SysDict dict) {
        return R.ok("新增成功", dictService.create(dict));
    }

    @Operation(summary = "修改字典")
    @PutMapping
    @OpLog(module = "数据字典", operation = "修改字典")
    public R<Void> update(@RequestBody SysDict dict) {
        dictService.update(dict);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除字典")
    @DeleteMapping("/{id}")
    @OpLog(module = "数据字典", operation = "删除字典")
    public R<Void> delete(@PathVariable("id") Long id) {
        dictService.delete(id);
        return R.ok("删除成功", null);
    }

    @Operation(summary = "新增字典类型")
    @PostMapping("/type")
    @OpLog(module = "数据字典", operation = "新增字典类型")
    public R<Long> createType(@RequestBody SysDictType type) {
        return R.ok("新增成功", dictService.createType(type));
    }
}