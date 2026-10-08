package com.gov.auth.controller;

import com.gov.api.dto.UserDTO;
import com.gov.auth.entity.SysUser;
import com.gov.auth.service.LoginLogService;
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
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * 认证中心控制器
 * <p>
 * 提供用户登录、Token 校验、登出等认证端点，以及供其他微服务调用的用户信息查询接口。
 * </p>
 *
 * <h3>核心流程</h3>
 * <ul>
 *     <li><b>登录</b> → 校验密码 → 生成 JWT → 记录登录日志</li>
 *     <li><b>登出</b> → 解析 Token 获取剩余有效期 → 写入 Redis 黑名单</li>
 *     <li><b>Token 校验</b> → 解析 JWT 返回载荷（供网关验证）</li>
 * </ul>
 *
 * @see com.gov.auth.util.JwtUtil
 * @see com.gov.auth.service.UserService
 */
@Tag(name = "认证中心", description = "登录、Token 校验")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private LoginLogService loginLogService;

    /**
     * 用户登录
     * <p>
     * 校验用户名密码后签发 JWT，同时记录登录日志（成功/失败均记录）。
     * 登录接口已配置为网关白名单，无需携带 Token。
     * </p>
     *
     * @param body 包含 username、password 的请求体
     * @param request 用于获取客户端 IP
     * @return 登录成功返回 token、用户信息等
     */
    @Operation(summary = "登录")
    @PostMapping("/login")
    @OpLog(module = "认证中心", operation = "用户登录", saveParams = false)
    public R<Map<String, Object>> login(@RequestBody Map<String, String> body,
                                        HttpServletRequest request) {
        String username = body.get("username");
        String password = body.get("password");

        SysUser user = userService.login(username, password);

        if (user == null) {
            loginLogService.record(username, null, "用户名或密码错误", false, request);
            throw new BizException(ResultCode.LOGIN_FAILED);
        }

        loginLogService.record(username, user.getTenantId(), "登录成功", true, request);

        // ★ 签发时带上部门与数据权限范围（原来调用的是不含 did/ds 的基础重载）。
        //   否则网关只能注入空 deptId + 默认 scope=3，服务端数据权限形同失效：
        //   fail-open 时表现为"越权看到全租户"，改成 fail-closed 后会变成"什么都看不到"。
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
        data.put("deptId", user.getDeptId());
        data.put("dataScope", user.getDataScope());
        return R.ok("登录成功", data);
    }

    /**
     * 校验 Token 有效性
     * <p>
     * 解析并验证 JWT 签名，返回载荷中的用户信息。
     * 主要供网关在转发请求前做二次校验，也可用于前端判断登录态是否过期。
     * </p>
     */
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

    /**
     * 用户登出
     * <p>
     * 将当前 Token 加入 Redis 黑名单，黑名单有效期与 Token 剩余有效期一致，
     * 避免无效占用内存。已过期的 Token 直接返回成功，不做处理。
     * </p>
     */
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
            Claims claims = jwtUtil.parse(token);
            long remainMs = claims.getExpiration().getTime() - System.currentTimeMillis();
            if (remainMs > 0) {
                redisService.set("token:blacklist:" + token, "1",
                        remainMs, java.util.concurrent.TimeUnit.MILLISECONDS);
            }
            return R.ok("登出成功", null);
        } catch (Exception e) {
            return R.ok("Token 已失效", null);
        }
    }

    /**
     * 按 ID 查询用户信息
     * <p>
     * 供其他微服务内部调用（通过 Feign），不走网关鉴权。
     * </p>
     */
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