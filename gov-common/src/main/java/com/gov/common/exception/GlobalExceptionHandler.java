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

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /** 业务异常 */
    @ExceptionHandler(BizException.class)
    public R<Void> handleBiz(BizException e, HttpServletRequest req) {
        log.warn("业务异常 [{} {}]: {}", req.getMethod(), req.getRequestURI(), e.getMessage());
        return R.fail(e.getCode(), e.getMessage());
    }

    /** 参数校验失败 */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public R<Void> handleValid(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldError() != null
                ? e.getBindingResult().getFieldError().getDefaultMessage()
                : ResultCode.PARAM_ERROR.getMsg();
        return R.fail(ResultCode.PARAM_ERROR.getCode(), msg);
    }

    /** 缺少请求头（比如 X-Tenant-Id） */
    @ExceptionHandler(MissingRequestHeaderException.class)
    public R<Void> handleMissingHeader(MissingRequestHeaderException e) {
        return R.fail(ResultCode.PARAM_ERROR.getCode(),
                "缺少请求头：" + e.getHeaderName());
    }

    /** JSON 解析失败 */
    @ExceptionHandler(org.springframework.http.converter.HttpMessageNotReadableException.class)
    public R<Void> handleJsonError(org.springframework.http.converter.HttpMessageNotReadableException e) {
        return R.fail(ResultCode.PARAM_ERROR.getCode(), "请求体格式错误");
    }

    /** 兜底：未捕获的异常 */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public R<Void> handleAll(Exception e, HttpServletRequest req) {
        log.error("系统异常 [{} {}]", req.getMethod(), req.getRequestURI(), e);
        return R.fail(ResultCode.FAIL.getCode(), "系统繁忙，请稍后重试");
    }

    @ExceptionHandler(org.springframework.web.servlet.resource.NoResourceFoundException.class)
    public R<Void> handleNoResource(org.springframework.web.servlet.resource.NoResourceFoundException e) {
        return R.fail(404, "资源不存在");
    }
}