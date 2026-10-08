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

/**
 * 操作日志切面
 * <p>
 * 使用 AOP {@code @Around} 拦截所有标注 {@link OpLog} 的方法，
 * 在方法执行前后采集请求上下文（URI、方法、用户、IP）、参数、耗时、异常信息，
 * 最终通过 {@link OperLogService} 入库。
 * </p>
 *
 * <p>关键设计：</p>
 * <ul>
 *   <li><b>非侵入</b> — 业务代码只需加注解，不需要手动记录日志</li>
 *   <li><b>脱敏保护</b> — 密码、身份证、手机号等敏感字段自动替换为 {@code ***}，避免明文入库</li>
 *   <li><b>参数安全</b> — 自动跳过 {@code MultipartFile}、{@code HttpServletRequest} 等不可序列化对象</li>
 *   <li><b>异常隔离</b> — 切面内部 try-catch，日志记录失败不影响主业务正常返回</li>
 *   <li><b>网关注入</b> — 用户 ID / 租户 ID 从请求头 {@code X-User-Id} / {@code X-Tenant-Id} 获取（由网关统一注入）</li>
 * </ul>
 *
 * @see OpLog
 * @see OperLog
 */
@Aspect
@Component
public class OperLogAspect {

    private static final Logger log = LoggerFactory.getLogger(OperLogAspect.class);
    private static final ObjectMapper OM = new ObjectMapper();

    /**
     * 敏感字段名集合，序列化请求参数时自动脱敏
     * <p>匹配 JSON 中 {@code "password":"xxx"} 的键值对，替换 value 为 {@code "***"}</p>
     */
    private static final Set<String> SENSITIVE_KEYS = Set.of(
            "password", "oldPassword", "newPassword",
            "idCard", "idCardNo", "idNumber",
            "phone", "mobile", "telephone",
            "secretKey", "accessKey", "secret",
            "bankCard", "cardNo", "cvv"
    );

    /** 脱敏正则：匹配 JSON 中键为敏感字段名的字符串值 */
    private static final Pattern SENSITIVE_PATTERN = Pattern.compile(
            "(\"(?:" + String.join("|", SENSITIVE_KEYS) + ")\"\\s*:\\s*)\"[^\"]*\"",
            Pattern.CASE_INSENSITIVE
    );

    @Autowired
    private OperLogService operLogService;

    /**
     * 环绕通知：拦截所有标注 {@link OpLog} 的方法
     * <p>执行流程：</p>
     * <ol>
     *   <li>记录开始时间</li>
     *   <li>执行原方法（{@code pjp.proceed()}）</li>
     *   <li>无论成功/失败，在 finally 中记录日志</li>
     *   <li>日志记录本身异常时仅打 error，不阻断主流程</li>
     * </ol>
     *
     * @param pjp  切入点
     * @param opLog 注解元数据
     * @return 原方法的返回值
     */
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

    /**
     * 组装并保存日志实体
     *
     * @param pjp  切入点（用于解析参数）
     * @param opLog 注解元数据
     * @param result 方法返回值（当前未使用，预留给 saveResult 功能）
     * @param error  方法抛出的异常，null 表示成功
     * @param cost   耗时（毫秒）
     */
    private void saveLog(ProceedingJoinPoint pjp, OpLog opLog,
                         Object result, Throwable error, long cost) {
        OperLog logEntity = new OperLog();
        logEntity.setModule(opLog.module());
        logEntity.setOperation(opLog.operation());
        logEntity.setCostMs(cost);
        // 成功=1，失败=0
        logEntity.setResult(error == null ? 1 : 0);
        if (error != null) {
            String msg = error.getMessage();
            // 取异常 message，截断到 500 字符；若 message 为 null 则记录异常简单类名
            logEntity.setErrorMsg(msg == null ? error.getClass().getSimpleName()
                    : msg.substring(0, Math.min(msg.length(), 500)));
        }

        // 从请求上下文采集 HTTP 层信息
        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs != null) {
            HttpServletRequest req = attrs.getRequest();
            logEntity.setMethod(req.getMethod());
            logEntity.setUri(req.getRequestURI());
            // 用户 ID / 租户 ID 由网关统一注入到请求头
            logEntity.setUserId(req.getHeader("X-User-Id"));
            logEntity.setTenantId(req.getHeader("X-Tenant-Id"));
            logEntity.setIp(getClientIp(req));

            if (opLog.saveParams()) {
                logEntity.setParams(serializeArgs(pjp));
            }
        }

        operLogService.save(logEntity);
    }

    /**
     * 获取客户端真实 IP
     * <p>
     * 按常见反向代理头优先级依次尝试：
     * {@code X-Forwarded-For} → {@code X-Real-IP} → {@code Proxy-Client-IP} →
     * {@code WL-Proxy-Client-IP} → {@code request.getRemoteAddr()}
     * 对于 {@code X-Forwarded-For} 可能包含多个 IP（逗号分隔），取第一个。
     * </p>
     *
     * @param req HTTP 请求
     * @return 客户端 IP 字符串
     */
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
     * 序列化方法参数为 JSON 字符串，经过以下安全处理：
     * <ol>
     *   <li>跳过文件上传、Request / Response / Session 等不可序列化的 Web 对象，替换为 {@code "[skip]"}</li>
     *   <li>使用 Jackson 序列化剩余参数</li>
     *   <li>敏感字段（密码、身份证、手机号等）自动脱敏为 {@code "***"}</li>
     *   <li>最终结果超过 2000 字符则截断并追加 {@code "...[truncated]"}</li>
     * </ol>
     *
     * @param pjp 切入点（含原始参数）
     * @return 处理后的 JSON 字符串
     */
    private String serializeArgs(ProceedingJoinPoint pjp) {
        Object[] args = pjp.getArgs();
        if (args == null || args.length == 0) {
            return "[]";
        }

        // 过滤不可序列化的 Web 对象
        List<Object> safe = new ArrayList<>();
        for (Object a : args) {
            if (a == null
                    || a instanceof MultipartFile
                    || a instanceof jakarta.servlet.ServletRequest
                    || a instanceof jakarta.servlet.ServletResponse
                    || a instanceof jakarta.servlet.http.HttpSession) {
                safe.add("[skip]");
            } else if (a instanceof String) {
                safe.add(a);
            } else {
                safe.add(a);
            }
        }

        try {
            String json = OM.writeValueAsString(safe);
            // 第 2 步：脱敏
            json = SENSITIVE_PATTERN.matcher(json).replaceAll("$1\"***\"");
            // 第 3 步：超长截断
            if (json.length() > 2000) {
                json = json.substring(0, 2000) + "...[truncated]";
            }
            return json;
        } catch (Exception e) {
            return "[serialize error: " + e.getClass().getSimpleName() + "]";
        }
    }
}