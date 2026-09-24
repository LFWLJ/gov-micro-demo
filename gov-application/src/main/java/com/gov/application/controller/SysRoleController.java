package com.gov.application.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.gov.application.dto.AssignMenuDTO;
import com.gov.application.dto.AssignUserDTO;
import com.gov.application.dto.RoleQueryDTO;
import com.gov.application.entity.SysRole;
import com.gov.application.service.SysRoleService;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "角色管理")
@RestController
@RequestMapping("/api/role")
public class SysRoleController {

    @Resource
    private SysRoleService sysRoleService;

    @Operation(summary = "分页查询角色")
    @PostMapping("/page")
    public R<IPage<SysRole>> page(@RequestBody RoleQueryDTO query) {
        return R.ok(sysRoleService.pageRoles(query));
    }

    @Operation(summary = "角色详情")
    @GetMapping("/{id}")
    public R<SysRole> detail(@PathVariable("id") Long id) {
        return R.ok(sysRoleService.pageRoles(new RoleQueryDTO()).getRecords()
                .stream().filter(r -> r.getId().equals(id)).findFirst().orElse(null));
    }

    @Operation(summary = "新增角色")
    @PostMapping
    public R<Void> add(@RequestBody SysRole role) {
        sysRoleService.addRole(role);
        return R.ok("新增成功", null);
    }

    @Operation(summary = "修改角色")
    @PutMapping
    public R<Void> update(@RequestBody SysRole role) {
        sysRoleService.updateRole(role);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除角色")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable("id") Long id) {
        sysRoleService.deleteRole(id);
        return R.ok("删除成功", null);
    }

    @Operation(summary = "查询角色已分配菜单ID")
    @GetMapping("/{id}/menus")
    public R<List<Long>> getMenus(@PathVariable("id") Long id) {
        return R.ok(sysRoleService.getMenuIds(id));
    }

    @Operation(summary = "分配菜单")
    @PutMapping("/{id}/menus")
    public R<Void> assignMenus(@PathVariable("id") Long id, @RequestBody AssignMenuDTO dto) {
        sysRoleService.assignMenus(id, dto);
        return R.ok("分配成功", null);
    }

    @Operation(summary = "查询角色已分配用户ID")
    @GetMapping("/{id}/users")
    public R<List<Long>> getUsers(@PathVariable("id") Long id) {
        return R.ok(sysRoleService.getUserIds(id));
    }

    @Operation(summary = "分配用户")
    @PutMapping("/{id}/users")
    public R<Void> assignUsers(@PathVariable("id") Long id, @RequestBody AssignUserDTO dto) {
        sysRoleService.assignUsers(id, dto);
        return R.ok("分配成功", null);
    }
}