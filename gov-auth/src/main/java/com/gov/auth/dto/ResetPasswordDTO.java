package com.gov.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * 重置他人密码请求（管理员操作）。
 */
@Schema(description = "重置密码请求")
public class ResetPasswordDTO {

    @Schema(description = "新密码", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "新密码不能为空")
    private String password;

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
