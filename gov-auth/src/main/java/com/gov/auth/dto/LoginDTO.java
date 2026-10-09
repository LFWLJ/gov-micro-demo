package com.gov.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 登录请求 DTO。
 *
 * <p>原来登录参数是裸的 {@code @RequestBody Map<String, String>}，
 * SpringDoc 只能为它生成 {@code additionalProperties: string} 这种「任意键值对象」schema，
 * Knife4j 的调试面板会把请求体渲染成**键值表单**并以
 * {@code application/x-www-form-urlencoded} 提交，与 {@code @RequestBody} 要求的 JSON
 * 不匹配，于是接口文档里点「调试」会得到 500（HttpMediaTypeNotSupportedException）。
 * 换成具名 DTO 后，文档页会给出正常的 JSON 编辑器，Content-Type 也就是 application/json。
 */
@Schema(description = "登录请求")
public class LoginDTO {

    @Schema(description = "用户名", example = "admin", requiredMode = Schema.RequiredMode.REQUIRED)
    private String username;

    @Schema(description = "密码", example = "123456", requiredMode = Schema.RequiredMode.REQUIRED)
    private String password;

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
