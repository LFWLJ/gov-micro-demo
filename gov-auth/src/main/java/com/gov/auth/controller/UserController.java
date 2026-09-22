package com.gov.auth.controller;

import com.gov.auth.dto.UserSaveDTO;
import com.gov.auth.service.UserService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.gov.auth.entity.SysUser;
import java.util.Map;


import java.util.Map;

@Tag(name = "用户管理")
@RestController
@RequestMapping("/api/auth/user")
public class UserController {

    @Autowired
    private UserService userService;

    @Operation(summary = "分页查询用户")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String keyword) {
        return R.ok(userService.page(page, size, keyword));
    }

    @Operation(summary = "新增用户")
    @PostMapping
    @OpLog(module = "用户管理", operation = "新增用户", saveParams = false)
    public R<Long> create(@RequestBody UserSaveDTO dto) {
        return R.ok("新增成功", userService.create(dto));
    }

    @Operation(summary = "获取当前用户信息")
    @GetMapping("/profile")
    public R<SysUser> profile(
            @RequestHeader(value = "X-User-Id", required = false) String userId) {
        if (userId == null || userId.isEmpty()) {
            return R.fail(401, "未登录");
        }
        SysUser user = userService.findById(Long.valueOf(userId));
        if (user == null) {
            return R.fail(404, "用户不存在");
        }
        // 脱敏：不返回密码
        user.setPassword(null);
        return R.ok(user);
    }

    @Operation(summary = "修改个人信息")
    @PutMapping("/profile")
    @OpLog(module = "个人中心", operation = "修改个人信息")
    public R<Void> updateProfile(
            @RequestHeader(value = "X-User-Id", required = false) String userId,
            @RequestBody Map<String, String> body) {
        if (userId == null || userId.isEmpty()) {
            return R.fail(401, "未登录");
        }
        userService.updateProfile(Long.valueOf(userId), body.get("realName"));
        return R.ok("修改成功", null);
    }

    @Operation(summary = "修改密码")
    @PutMapping("/password")
    @OpLog(module = "个人中心", operation = "修改密码", saveParams = false)
    public R<Void> changePassword(
            @RequestHeader(value = "X-User-Id", required = false) String userId,
            @RequestBody Map<String, String> body) {
        if (userId == null || userId.isEmpty()) {
            return R.fail(401, "未登录");
        }
        userService.changePassword(
                Long.valueOf(userId),
                body.get("oldPassword"),
                body.get("newPassword")
        );
        return R.ok("密码修改成功", null);
    }

    @Operation(summary = "修改用户")
    @PutMapping
    @OpLog(module = "用户管理", operation = "修改用户")
    public R<Void> update(@RequestBody UserSaveDTO dto) {
        userService.update(dto);
        return R.ok("修改成功", null);
    }

    @Operation(summary = "删除用户")
    @DeleteMapping("/{id}")
    @OpLog(module = "用户管理", operation = "删除用户")
    public R<Void> delete(@PathVariable("id") Long id) {
        userService.delete(id);
        return R.ok("删除成功", null);
    }

    @Operation(summary = "重置密码")
    @PostMapping("/{id}/reset-password")
    @OpLog(module = "用户管理", operation = "重置密码", saveParams = false)
    public R<Void> resetPassword(@PathVariable("id") Long id,
                                 @RequestBody Map<String, String> body) {
        userService.resetPassword(id, body.get("password"));
        return R.ok("密码已重置", null);
    }
}