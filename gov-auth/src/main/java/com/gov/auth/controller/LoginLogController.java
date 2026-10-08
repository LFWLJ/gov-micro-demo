package com.gov.auth.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.auth.entity.LoginLog;
import com.gov.auth.mapper.LoginLogMapper;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 登录日志查询接口
 * <p>
 * 只读接口，直接走 Mapper 分页查询 {@code sys_login_log}。
 * 支持按用户名模糊搜索 + 状态（0 失败 / 1 成功）过滤。
 * 该表同样在租户插件的忽略列表里，因此查询是跨租户可见的（用于审计场景）。
 * </p>
 */
@Tag(name = "登录日志")
@RestController
@RequestMapping("/api/auth/login-log")
public class LoginLogController {

    @Autowired
    private LoginLogMapper loginLogMapper;

    @Operation(summary = "分页查询登录日志")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "username", required = false) String username,
            @RequestParam(value = "status", required = false) Integer status) {

        LambdaQueryWrapper<LoginLog> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(username)) {
            wrapper.like(LoginLog::getUsername, username);
        }
        if (status != null) {
            wrapper.eq(LoginLog::getStatus, status);
        }
        wrapper.orderByDesc(LoginLog::getId);

        Page<LoginLog> p = new Page<>(page, size);
        Page<LoginLog> result = loginLogMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return R.ok(data);
    }
}