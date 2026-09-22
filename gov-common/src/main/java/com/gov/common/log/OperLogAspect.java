package com.gov.common.log;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

@Aspect
@Component
public class OperLogAspect {

    private static final Logger log = LoggerFactory.getLogger(OperLogAspect.class);
    private static final ObjectMapper OM = new ObjectMapper();

    /** 敏感字段，入库前脱敏 */
    private static final Set<String> SENSITIVE_KEYS = Set.of(
            "password", "oldPassword", "newPassword",
            "idCard", "idCardNo", "idNumber",
            "phone", "mobile", "telephone",
            "secretKey", "accessKey", "secret",
            "bankCard", "cardNo", "cvv"
    );

    /** 脱敏正则：匹配 "key":"value" 形式的 JSON */
    private static final Pattern SENSITIVE_PATTERN = Pattern.compile(
            "(\"(?:" + String.join("|", SENSITIVE_KEYS) + ")\"\\s*:\\s*)\"[^\"]*\"",
            Pattern.CASE_INSENSITIVE
    );

    @Autowired
    private OperLogService operLogService;

    @Around("@annotation(opLog)")
    public Object around(ProceedingJoinPoint pjp, OpLog opLog) throws Throwable {
        long start = System.currentTimeMillis();
        Object result = null;
        Throwable error = null;

        try {
            result = pjp.proceed();
            return result;
        } catch (Throwable t) {
            error = t;
            throw t;
        } finally {
            try {
                saveLog(pjp, opLog, result, error, System.currentTimeMillis() - start);
            } catch (Exception e) {
                log.error("记录操作日志异常", e);
            }
        }
    }

    private void saveLog(ProceedingJoinPoint pjp, OpLog opLog,
                         Object result, Throwable error, long cost) {
        OperLog logEntity = new OperLog();
        logEntity.setModule(opLog.module());
        logEntity.setOperation(opLog.operation());
        logEntity.setCostMs(cost);
        logEntity.setResult(error == null ? 1 : 0);
        if (error != null) {
            String msg = error.getMessage();
            logEntity.setErrorMsg(msg == null ? error.getClass().getSimpleName()
                    : msg.substring(0, Math.min(msg.length(), 500)));
        }

        // 请求上下文
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs != null) {
            HttpServletRequest req = attrs.getRequest();
            logEntity.setMethod(req.getMethod());
            logEntity.setUri(req.getRequestURI());
            logEntity.setUserId(req.getHeader("X-User-Id"));
            logEntity.setTenantId(req.getHeader("X-Tenant-Id"));
            logEntity.setIp(getClientIp(req));

            if (opLog.saveParams()) {
                logEntity.setParams(serializeArgs(pjp));
            }
        }

        operLogService.save(logEntity);
    }

    /** 获取客户端真实 IP（兼容代理场景） */
    private String getClientIp(HttpServletRequest req) {
        String[] headers = {"X-Forwarded-For", "X-Real-IP", "Proxy-Client-IP", "WL-Proxy-Client-IP"};
        for (String h : headers) {
            String ip = req.getHeader(h);
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                int idx = ip.indexOf(',');
                return idx > 0 ? ip.substring(0, idx).trim() : ip;
            }
        }
        return req.getRemoteAddr();
    }

    /**
     * 序列化参数：
     * 1. 跳过文件、Request、Response 等不可序列化对象
     * 2. 对敏感字段脱敏
     * 3. 超长截断到 2000 字符
     */
    private String serializeArgs(ProceedingJoinPoint pjp) {
        Object[] args = pjp.getArgs();
        if (args == null || args.length == 0) {
            return "[]";
        }

        List<Object> safe = new ArrayList<>();
        for (Object a : args) {
            if (a == null
                    || a instanceof MultipartFile
                    || a instanceof jakarta.servlet.ServletRequest
                    || a instanceof jakarta.servlet.ServletResponse
                    || a instanceof jakarta.servlet.http.HttpSession) {
                safe.add("[skip]");
            } else if (a instanceof String) {
                // 字符串参数原样放，序列化后会是带引号的字符串
                safe.add(a);
            } else {
                safe.add(a);
            }
        }

        try {
            String json = OM.writeValueAsString(safe);
            // 脱敏
            json = SENSITIVE_PATTERN.matcher(json).replaceAll("$1\"***\"");
            // 截断
            if (json.length() > 2000) {
                json = json.substring(0, 2000) + "...[truncated]";
            }
            return json;
        } catch (Exception e) {
            return "[serialize error: " + e.getClass().getSimpleName() + "]";
        }
    }
}