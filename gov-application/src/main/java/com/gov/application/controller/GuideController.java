package com.gov.application.controller;

import com.gov.application.entity.Guide;
import com.gov.application.service.GuideService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "办事指南")
@RestController
@RequestMapping("/api/guide")
public class GuideController {

    @Autowired
    private GuideService guideService;

    @Operation(summary = "分页查询")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "category", required = false) String category) {
        return R.ok(guideService.page(page, size, keyword, category));
    }

    @Operation(summary = "查询所有分类")
    @GetMapping("/categories")
    public R<List<String>> categories() {
        return R.ok(guideService.listCategories());
    }

    @Operation(summary = "按ID查询")
    @GetMapping("/{id}")
    public R<Guide> getById(@PathVariable("id") Long id) {
        Guide guide = guideService.getById(id);
        if (guide == null) return R.fail(404, "指南不存在");
        return R.ok(guide);
    }

    @Operation(summary = "新增指南")
    @PostMapping
    @OpLog(module = "办事指南", operation = "新增指南")
    public R<Long> create(@RequestBody Guide guide) {
        return R.ok("新增成功", guideService.create(guide));
    }

    @Operation(summary = "修改指南")
    @PutMapping
    @OpLog(module = "办事指南", operation = "修改指南")
    public R<Void> update(@RequestBody Guide guide) {
        guideService.update(guide);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除指南")
    @DeleteMapping("/{id}")
    @OpLog(module = "办事指南", operation = "删除指南")
    public R<Void> delete(@PathVariable("id") Long id) {
        guideService.delete(id);
        return R.ok("删除成功", null);
    }

    @Operation(summary = "启用/停用")
    @PostMapping("/{id}/status/{status}")
    @OpLog(module = "办事指南", operation = "切换状态")
    public R<Void> toggleStatus(@PathVariable("id") Long id,
                                @PathVariable("status") Integer status) {
        guideService.toggleStatus(id, status);
        return R.ok("操作成功", null);
    }
}