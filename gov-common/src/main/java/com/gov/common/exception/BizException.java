package com.gov.common.exception;

import com.gov.common.result.ResultCode;

/**
 * 业务异常
 * <p>
 * 在业务逻辑中抛出的运行时异常，全局由 {@link GlobalExceptionHandler} 捕获并统一封装为 {@code R.fail(code, msg)} 返回。
 * 该异常携带业务错误码 {@code code}，前端可据此判断处理方式。
 * </p>
 *
 * @see GlobalExceptionHandler
 * @see ResultCode
 */
public class BizException extends RuntimeException {

    /** 业务错误码 */
    private final int code;

    /**
     * 使用默认错误码 {@link ResultCode#FAIL} 构造业务异常
     *
     * @param msg 异常提示信息
     */
    public BizException(String msg) {
        super(msg);
        this.code = ResultCode.FAIL.getCode();
    }

    /**
     * 使用标准响应码枚举构造业务异常
     *
     * @param rc 标准响应码，同时提供 code 与 msg
     */
    public BizException(ResultCode rc) {
        super(rc.getMsg());
        this.code = rc.getCode();
    }

    /**
     * 使用自定义错误码和消息构造业务异常
     *
     * @param code 业务错误码
     * @param msg  异常提示信息
     */
    public BizException(int code, String msg) {
        super(msg);
        this.code = code;
    }

    /**
     * 获取业务错误码
     *
     * @return 错误码
     */
    public int getCode() {
        return code;
    }
}