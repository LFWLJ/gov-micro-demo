package com.gov.application.controller;

import com.gov.application.entity.Dept;
import com.gov.application.service.DeptService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "部门管理")
@RestController
@RequestMapping("/api/dept")
public class DeptController {

    @Autowired
    private DeptService deptService;

    @Operation(summary = "查询部门树")
    @GetMapping("/tree")
    public R<List<Dept>> tree() {
        return R.ok(deptService.tree());
    }

    @Operation(summary = "新增部门")
    @PostMapping
    @OpLog(module = "部门管理", operation = "新增部门")
    public R<Long> create(@RequestBody Dept dept) {
        return R.ok("新增成功", deptService.create(dept));
    }

    @Operation(summary = "修改部门")
    @PutMapping
    @OpLog(module = "部门管理", operation = "修改部门")
    public R<Void> update(@RequestBody Dept dept) {
        deptService.update(dept);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除部门")
    @DeleteMapping("/{id}")
    @OpLog(module = "部门管理", operation = "删除部门")
    public R<Void> delete(@PathVariable("id") Long id) {
        deptService.delete(id);
        return R.ok("删除成功", null);
    }
}