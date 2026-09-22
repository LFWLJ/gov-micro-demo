package com.gov.common.result;

public enum ResultCode {

    SUCCESS(200, "操作成功"),
    FAIL(500, "操作失败"),

    // 参数、权限
    PARAM_ERROR(400, "参数错误"),
    UNAUTHORIZED(401, "未登录或Token已过期"),
    FORBIDDEN(403, "无权访问"),
    NOT_FOUND(404, "资源不存在"),

    // 业务
    LOGIN_FAILED(1001, "用户名或密码错误"),
    USER_DISABLED(1002, "账号已被禁用"),
    TENANT_MISSING(1003, "缺少租户标识"),

    // 流程
    PROCESS_START_FAILED(2001, "流程发起失败"),
    TASK_NOT_FOUND(2002, "任务不存在或无权处理"),
    TASK_COMPLETE_FAILED(2003, "任务处理失败");

    private final int code;
    private final String msg;

    ResultCode(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public int getCode() { return code; }
    public String getMsg() { return msg; }
}