package com.gov.auth.service;

import com.gov.auth.entity.LoginLog;
import com.gov.auth.mapper.LoginLogMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class LoginLogService {

    @Autowired
    private LoginLogMapper loginLogMapper;

    /** 记录登录日志 */
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
            // 日志记录失败不影响登录
        }
    }

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

    private String parseBrowser(String ua) {
        if (ua == null) return "Unknown";
        if (ua.contains("Edg")) return "Edge";
        if (ua.contains("Chrome")) return "Chrome";
        if (ua.contains("Firefox")) return "Firefox";
        if (ua.contains("Safari")) return "Safari";
        return "Other";
    }

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