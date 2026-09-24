package com.gov.auth.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.gov.auth.dto.TenantQueryDTO;
import com.gov.auth.entity.SysTenant;
import com.gov.auth.service.SysTenantService;
import com.gov.common.perm.RequiresPerm;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@Tag(name = "租户管理")
@RestController
@RequestMapping("/api/auth/tenant")
public class SysTenantController {

    @Autowired
    private SysTenantService sysTenantService;

    @Operation(summary = "分页查询租户")
    @PostMapping("/page")
    public R<IPage<SysTenant>> page(@RequestBody TenantQueryDTO query) {
        return R.ok(sysTenantService.pageTenants(query));
    }

    @Operation(summary = "租户详情")
    @GetMapping("/{id}")
    public R<SysTenant> detail(@PathVariable("id") Long id) {
        return R.ok(sysTenantService.getById(id));
    }

    @Operation(summary = "新增租户")
    @RequiresPerm("sys:tenant:add")
    @PostMapping
    public R<Void> add(@RequestBody SysTenant tenant) {
        sysTenantService.addTenant(tenant);
        return R.ok("新增成功", null);
    }

    @Operation(summary = "修改租户")
    @RequiresPerm("sys:tenant:edit")
    @PutMapping
    public R<Void> update(@RequestBody SysTenant tenant) {
        sysTenantService.updateTenant(tenant);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除租户")
    @RequiresPerm("sys:tenant:del")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable("id") Long id) {
        sysTenantService.deleteTenant(id);
        return R.ok("删除成功", null);
    }
}