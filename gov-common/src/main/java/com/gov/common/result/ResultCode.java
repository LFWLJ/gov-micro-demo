package com.gov.common.result;

/**
 * 标准业务响应码枚举
 * <p>
 * 业务状态码分段约定：
 * <ul>
 *   <li>{@code 200} — HTTP 语义的成功</li>
 *   <li>{@code 4xx} — 参数 / 鉴权 / 权限错误，与 HTTP 状态码对齐</li>
 *   <li>{@code 500} — 通用失败</li>
 *   <li>{@code 1000~1999} — 认证与租户相关业务错误</li>
 *   <li>{@code 2000~2999} — 流程 / 任务相关业务错误</li>
 * </ul>
 * 后续新增业务错误码请继续按业务域分段，避免冲突。
 *
 * @see R
 */
public enum ResultCode {

    /** 成功 */
    SUCCESS(200, "操作成功"),
    /** 通用失败 */
    FAIL(500, "操作失败"),

    // ---------- 参数、权限（HTTP 语义对齐） ----------
    /** 参数错误 */
    PARAM_ERROR(400, "参数错误"),
    /** 未登录或 Token 已过期 */
    UNAUTHORIZED(401, "未登录或Token已过期"),
    /** 无权访问（鉴权通过但权限不足） */
    FORBIDDEN(403, "无权访问"),
    /** 资源不存在 */
    NOT_FOUND(404, "资源不存在"),

    // ---------- 认证 / 租户（1000 段） ----------
    /** 用户名或密码错误 */
    LOGIN_FAILED(1001, "用户名或密码错误"),
    /** 账号已被禁用 */
    USER_DISABLED(1002, "账号已被禁用"),
    /** 多租户场景缺少租户标识 */
    TENANT_MISSING(1003, "缺少租户标识"),

    // ---------- 流程 / 任务（2000 段） ----------
    /** 流程发起失败 */
    PROCESS_START_FAILED(2001, "流程发起失败"),
    /** 任务不存在或无权处理 */
    TASK_NOT_FOUND(2002, "任务不存在或无权处理"),
    /** 任务处理失败 */
    TASK_COMPLETE_FAILED(2003, "任务处理失败");

    /** 业务状态码 */
    private final int code;
    /** 提示信息 */
    private final String msg;

    ResultCode(int code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public int getCode() { return code; }
    public String getMsg() { return msg; }
}