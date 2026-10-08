package com.gov.common.exception;

import com.gov.common.result.R;
import com.gov.common.result.ResultCode;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingRequestHeaderException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器
 * <p>
 * 基于 Spring MVC 的 {@link RestControllerAdvice}，对 Controller 层抛出的异常做统一拦截与封装，
 * 避免将原始堆栈直接暴露给前端，同时按异常类型做差异化的日志记录和错误码返回。
 * </p>
 *
 * <p>处理策略：</p>
 * <ul>
 *   <li>{@link BizException} — 业务层主动抛出，warn 级别日志，保留业务方指定的错误码与消息</li>
 *   <li>{@link MethodArgumentNotValidException} — {@code @Valid} / {@code @Validated} 参数校验失败</li>
 *   <li>{@link MissingRequestHeaderException} — 缺少必填请求头（如网关传入的 {@code X-Tenant-Id}）</li>
 *   <li>{@link org.springframework.http.converter.HttpMessageNotReadableException} — JSON 解析失败</li>
 *   <li>{@link org.springframework.web.servlet.resource.NoResourceFoundException} — 404 资源不存在</li>
 *   <li>{@link Exception}（兜底）— 所有未匹配的异常，error 级别日志，HTTP 500</li>
 * </ul>
 *
 * @see BizException
 * @see R
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** 日志记录器 */
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * 处理业务异常 {@link BizException}
     * <p>由业务逻辑主动抛出，如参数校验不通过、资源已删除、数据冲突等。使用 warn 级别避免业务异常刷屏 error 日志。</p>
     *
     * @param e   业务异常
     * @param req 当前 HTTP 请求（用于记录方法和 URL）
     * @return 统一失败响应
     */
    @ExceptionHandler(BizException.class)
    public R<Void> handleBiz(BizException e, HttpServletRequest req) {
        log.warn("业务异常 [{} {}]: {}", req.getMethod(), req.getRequestURI(), e.getMessage());
        return R.fail(e.getCode(), e.getMessage());
    }

    /**
     * 处理 Spring Validation 参数校验失败
     * <p>优先取第一个字段的校验消息（{@code @NotBlank} / {@code @Size} 等声明的 message），
     * 若无则回退到 {@link ResultCode#PARAM_ERROR} 的默认文案。</p>
     *
     * @param e 参数校验异常
     * @return 统一失败响应，携带具体字段校验信息
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public R<Void> handleValid(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldError() != null
                ? e.getBindingResult().getFieldError().getDefaultMessage()
                : ResultCode.PARAM_ERROR.getMsg();
        return R.fail(ResultCode.PARAM_ERROR.getCode(), msg);
    }

    /**
     * 处理缺少请求头的异常
     * <p>常见于多租户场景下缺少 {@code X-Tenant-Id}，或鉴权场景下缺少 {@code Authorization}。</p>
     *
     * @param e 缺失请求头异常
     * @return 统一失败响应，明确告知缺失的请求头名称
     */
    @ExceptionHandler(MissingRequestHeaderException.class)
    public R<Void> handleMissingHeader(MissingRequestHeaderException e) {
        return R.fail(ResultCode.PARAM_ERROR.getCode(),
                "缺少请求头：" + e.getHeaderName());
    }

    /**
     * 处理 JSON 反序列化异常
     * <p>请求体格式错误（如缺少引号、类型不匹配）时 Spring MVC 抛出，提示前端检查 JSON 格式。</p>
     *
     * @param e 消息不可读异常
     * @return 统一失败响应
     */
    @ExceptionHandler(org.springframework.http.converter.HttpMessageNotReadableException.class)
    public R<Void> handleJsonError(org.springframework.http.converter.HttpMessageNotReadableException e) {
        return R.fail(ResultCode.PARAM_ERROR.getCode(), "请求体格式错误");
    }

    /**
     * 兜底处理：捕获所有未匹配的异常
     * <p>理论上不应命中（命中意味着代码有未考虑到的问题），以 error 级别打印完整堆栈便于排查。</p>
     *
     * @param e   未捕获的异常
     * @param req 当前 HTTP 请求
     * @return 统一失败响应，HTTP 状态码 500，对外隐藏具体堆栈
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public R<Void> handleAll(Exception e, HttpServletRequest req) {
        log.error("系统异常 [{} {}]", req.getMethod(), req.getRequestURI(), e);
        return R.fail(ResultCode.FAIL.getCode(), "系统繁忙，请稍后重试");
    }

    /**
     * 处理静态资源不存在异常（Spring Boot 3.x）
     *
     * @param e 资源不存在异常
     * @return 404 响应
     */
    @ExceptionHandler(org.springframework.web.servlet.resource.NoResourceFoundException.class)
    public R<Void> handleNoResource(org.springframework.web.servlet.resource.NoResourceFoundException e) {
        return R.fail(404, "资源不存在");
    }
}