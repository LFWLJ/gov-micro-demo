package com.gov.application.controller;

import com.gov.application.entity.SysMenu;
import com.gov.application.service.SysMenuService;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "菜单管理")
@RestController
@RequestMapping("/api/menu")
public class SysMenuController {

    @Resource
    private SysMenuService sysMenuService;

    @Operation(summary = "菜单树")
    @GetMapping("/tree")
    public R<List<SysMenu>> tree() {
        return R.ok(sysMenuService.menuTree());
    }

    @Operation(summary = "扁平列表")
    @GetMapping("/list")
    public R<List<SysMenu>> list() {
        return R.ok(sysMenuService.listAll());
    }

    @Operation(summary = "菜单详情")
    @GetMapping("/{id}")
    public R<SysMenu> detail(@PathVariable("id") Long id) {
        return R.ok(sysMenuService.getById(id));
    }

    @Operation(summary = "新增菜单")
    @PostMapping
    public R<Void> add(@RequestBody SysMenu menu) {
        sysMenuService.addMenu(menu);
        return R.ok("新增成功", null);
    }

    @Operation(summary = "修改菜单")
    @PutMapping
    public R<Void> update(@RequestBody SysMenu menu) {
        sysMenuService.updateMenu(menu);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除菜单")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable("id") Long id) {
        sysMenuService.deleteMenu(id);
        return R.ok("删除成功", null);
    }

    @Operation(summary = "某角色已分配的菜单ID")
    @GetMapping("/role/{roleId}")
    public R<List<Long>> menuIdsByRole(@PathVariable("roleId") Long roleId) {
        return R.ok(sysMenuService.menuIdsByRole(roleId));
    }

    // ==================== 新增：动态路由 ====================

    @Operation(summary = "当前用户的路由菜单树")
    @GetMapping("/routers")
    public R<List<SysMenu>> routers() {
        return R.ok(sysMenuService.getRouters());
    }

    @Operation(summary = "当前用户的按钮权限标识")
    @GetMapping("/permissions")
    public R<List<String>> permissions() {
        return R.ok(sysMenuService.getPermissions());
    }
}