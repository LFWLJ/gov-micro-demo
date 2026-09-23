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