package com.gov.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * 回复工单请求。
 *
 * <p>校验消息与服务层原有提示保持一致（"回复内容不能为空"）。
 */
@Schema(description = "回复工单请求")
public class ConsultReplyDTO {

    @Schema(description = "回复内容", example = "已安排窗口加快办理", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "回复内容不能为空")
    private String reply;

    public String getReply() { return reply; }
    public void setReply(String reply) { this.reply = reply; }
}
