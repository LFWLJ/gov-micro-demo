package com.gov.common.exception;

import com.gov.common.result.ResultCode;

public class BizException extends RuntimeException {

    private final int code;

    public BizException(String msg) {
        super(msg);
        this.code = ResultCode.FAIL.getCode();
    }

    public BizException(ResultCode rc) {
        super(rc.getMsg());
        this.code = rc.getCode();
    }

    public BizException(int code, String msg) {
        super(msg);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}