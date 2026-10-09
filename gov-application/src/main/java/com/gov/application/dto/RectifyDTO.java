package com.gov.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * 差评整改请求。
 */
@Schema(description = "差评整改请求")
public class RectifyDTO {

    @Schema(description = "整改内容", example = "已加强窗口人员培训", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "整改内容不能为空")
    private String content;

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
}
