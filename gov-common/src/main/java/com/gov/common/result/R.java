package com.gov.common.result;

import io.swagger.v3.oas.annotations.media.Schema;

import java.io.Serializable;

/**
 * 统一响应体
 * <p>
 * 所有 Controller 的接口返回值统一使用该泛型类包装，包含：
 * <ul>
 *   <li>{@code code} — 业务状态码，约定 200 为成功，其余为各类错误（详见 {@link ResultCode}）</li>
 *   <li>{@code msg} — 提示信息，前端可直接展示</li>
 *   <li>{@code data} — 业务数据，成功时返回，失败时通常为 {@code null}</li>
 * </ul>
 *
 * <p>示例：</p>
 * <pre>{@code
 * return R.ok(user);                        // 成功 + 数据
 * return R.ok();                             // 成功 + 无数据
 * return R.fail("角色标识已存在");             // 失败 + 默认错误码 500
 * return R.fail(ResultCode.UNAUTHORIZED);    // 失败 + 标准响应码
 * }</pre>
 *
 * @param <T> 业务数据类型
 * @see ResultCode
 */
@Schema(description = "统一响应体")
public class R<T> implements Serializable {

    /** 状态码，200 表示成功 */
    @Schema(description = "状态码，200 表示成功")
    private int code;

    /** 提示信息 */
    @Schema(description = "提示信息")
    private String msg;

    /** 业务数据 */
    @Schema(description = "业务数据")
    private T data;

    public R() {}

    public R(int code, String msg, T data) {
        this.code = code;
        this.msg = msg;
        this.data = data;
    }

    /** 构造成功响应（无数据） */
    public static <T> R<T> ok() {
        return new R<>(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMsg(), null);
    }

    /** 构造成功响应（携带业务数据，默认成功提示） */
    public static <T> R<T> ok(T data) {
        return new R<>(ResultCode.SUCCESS.getCode(), ResultCode.SUCCESS.getMsg(), data);
    }

    /** 构造成功响应（携带业务数据和自定义成功提示） */
    public static <T> R<T> ok(String msg, T data) {
        return new R<>(ResultCode.SUCCESS.getCode(), msg, data);
    }

    /** 构造失败响应（默认错误码 FAIL，自定义消息） */
    public static <T> R<T> fail(String msg) {
        return new R<>(ResultCode.FAIL.getCode(), msg, null);
    }

    /** 构造失败响应（自定义错误码和消息） */
    public static <T> R<T> fail(int code, String msg) {
        return new R<>(code, msg, null);
    }

    /** 构造失败响应（使用标准响应码枚举） */
    public static <T> R<T> fail(ResultCode rc) {
        return new R<>(rc.getCode(), rc.getMsg(), null);
    }

    public int getCode() { return code; }
    public void setCode(int code) { this.code = code; }

    public String getMsg() { return msg; }
    public void setMsg(String msg) { this.msg = msg; }

    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
}