package com.gov.auth.service.impl;

import com.gov.auth.entity.LoginLog;
import com.gov.auth.mapper.LoginLogMapper;
import com.gov.auth.service.LoginLogService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * 登录日志记录实现
 * <p>
 * 负责把每次登录尝试（成功/失败）落库到 {@code sys_login_log}，同时解析客户端 IP、
 * 浏览器、操作系统。整个 record 方法用 try-catch 包裹并吞异常，保证「写日志失败
 * 不影响登录主流程」。
 * </p>
 * <p>
 * IP 解析按代理链路从外到内依次尝试：X-Forwarded-For → X-Real-IP → Proxy-Client-IP
 * → RemoteAddr；X-Forwarded-For 可能是逗号分隔的整条链路，取第一段作为真实来源 IP。
 * UA 解析用简单的字符串 contains 匹配，够用即可，不引入额外依赖。
 * </p>
 */
@Service
public class LoginLogServiceImpl implements LoginLogService {

    @Autowired
    private LoginLogMapper loginLogMapper;

    /**
     * 记录一次登录尝试
     *
     * @param username 登录账号
     * @param tenantId 所属租户
     * @param msg      登录结果描述（如 "密码错误" / "登录成功"）
     * @param success  是否成功
     * @param request  用于提取 IP / UA，可为 null（单元测试场景）
     */
    @Override
    public void record(String username, String tenantId, String msg,
                       boolean success, HttpServletRequest request) {
        try {
            LoginLog log = new LoginLog();
            log.setUsername(username);
            log.setTenantId(tenantId);
            log.setMsg(msg);
            log.setStatus(success ? 1 : 0);
            log.setLoginTime(LocalDateTime.now());

            if (request != null) {
                log.setIp(getClientIp(request));
                String ua = request.getHeader("User-Agent");
                log.setBrowser(parseBrowser(ua));
                log.setOs(parseOs(ua));
            }

            loginLogMapper.insert(log);
        } catch (Exception e) {
        }
    }

    /**
     * 解析真实客户端 IP（穿透反向代理 / 负载均衡）
     * <p>
     * 优先级：X-Forwarded-For → X-Real-IP → Proxy-Client-IP → RemoteAddr。
     * X-Forwarded-For 可能形如 {@code 203.0.113.5, 10.0.0.1}，取第一段即为真实来源。
     * 遇到 "unknown" 占位头也会跳过。
     * </p>
     */
    private String getClientIp(HttpServletRequest req) {
        String[] headers = {"X-Forwarded-For", "X-Real-IP", "Proxy-Client-IP"};
        for (String h : headers) {
            String ip = req.getHeader(h);
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                int idx = ip.indexOf(',');
                return idx > 0 ? ip.substring(0, idx).trim() : ip;
            }
        }
        return req.getRemoteAddr();
    }

    /** 从 User-Agent 粗略识别浏览器 */
    private String parseBrowser(String ua) {
        if (ua == null) return "Unknown";
        if (ua.contains("Edg")) return "Edge";
        if (ua.contains("Chrome")) return "Chrome";
        if (ua.contains("Firefox")) return "Firefox";
        if (ua.contains("Safari")) return "Safari";
        return "Other";
    }

    /** 从 User-Agent 粗略识别操作系统 */
    private String parseOs(String ua) {
        if (ua == null) return "Unknown";
        if (ua.contains("Windows")) return "Windows";
        if (ua.contains("Mac")) return "macOS";
        if (ua.contains("Linux")) return "Linux";
        if (ua.contains("Android")) return "Android";
        if (ua.contains("iPhone") || ua.contains("iPad")) return "iOS";
        return "Other";
    }
}