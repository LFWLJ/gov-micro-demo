package com.gov.auth.controller;

import com.gov.api.dto.UserDTO;
import com.gov.auth.entity.SysUser;
import com.gov.auth.service.UserService;
import com.gov.auth.util.JwtUtil;
import com.gov.common.log.OpLog;
import com.gov.common.redis.RedisService;
import com.gov.common.result.R;
import com.gov.common.result.ResultCode;
import com.gov.common.exception.BizException;
import io.jsonwebtoken.Claims;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "认证中心", description = "登录、Token 校验")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;


    @Operation(summary = "登录", description = "用户名密码登录，返回 JWT Token")
    @PostMapping("/login")
    @OpLog(module = "认证中心", operation = "用户登录", saveParams = false)
    public R<Map<String, Object>> login(@RequestBody Map<String, String> body) {
        String username = body.get("username");
        String password = body.get("password");

        SysUser user = userService.login(username, password);
        if (user == null) {
            throw new BizException(ResultCode.LOGIN_FAILED);
        }

        String token = jwtUtil.createToken(
                String.valueOf(user.getId()),
                user.getTenantId(),
                user.getRoles(),
                user.getDeptId(),
                user.getDataScope()
        );

        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("userId", user.getId());
        data.put("tenantId", user.getTenantId());
        data.put("roles", user.getRoles());
        data.put("realName", user.getRealName());
        return R.ok("登录成功", data);
    }

    @Operation(summary = "校验 Token")
    @GetMapping("/verify")
    public R<Map<String, Object>> verify(
            @Parameter(description = "Bearer Token")
            @RequestHeader(value = "Authorization", required = false) String auth) {
        if (auth == null || !auth.startsWith("Bearer ")) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
        try {
            Claims claims = jwtUtil.parse(auth.substring(7));
            Map<String, Object> data = new HashMap<>();
            data.put("userId", claims.get("uid"));
            data.put("tenantId", claims.get("tid"));
            data.put("roles", claims.get("roles"));
            return R.ok(data);
        } catch (Exception e) {
            throw new BizException(ResultCode.UNAUTHORIZED);
        }
    }

    @Autowired
    private RedisService redisService;

    @Operation(summary = "登出", description = "将当前 Token 加入黑名单")
    @PostMapping("/logout")
    @OpLog(module = "认证中心", operation = "用户登出")
    public R<Void> logout(
            @RequestHeader(value = "Authorization", required = false) String auth) {
        if (auth == null || !auth.startsWith("Bearer ")) {
            return R.ok("未登录", null);
        }
        String token = auth.substring(7);
        try {
            // 解析 Token 拿到剩余有效期
            Claims claims = jwtUtil.parse(token);
            long remainMs = claims.getExpiration().getTime() - System.currentTimeMillis();
            if (remainMs > 0) {
                // 把 Token 加入黑名单，有效期与 Token 剩余时间一致
                redisService.set("token:blacklist:" + token, "1",
                        remainMs, java.util.concurrent.TimeUnit.MILLISECONDS);
            }
            return R.ok("登出成功", null);
        } catch (Exception e) {
            return R.ok("Token 已失效", null);
        }
    }



    @Operation(summary = "按ID查询用户信息（供其他服务调用）")
    @GetMapping("/user/info")
    public R<UserDTO> getUserInfo(@RequestParam("userId") Long userId) {
        SysUser user = userService.findById(userId);
        if (user == null) {
            return R.fail(404, "用户不存在");
        }
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setRealName(user.getRealName());
        dto.setTenantId(user.getTenantId());
        dto.setRoles(user.getRoles());
        return R.ok(dto);
    }

}