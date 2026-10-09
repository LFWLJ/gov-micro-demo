package com.gov.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 取消预约请求。
 *
 * <p>请求体可省略（不填原因也能取消），因此字段不加 {@code @NotBlank}。
 */
@Schema(description = "取消预约请求")
public class AppointmentCancelDTO {

    @Schema(description = "取消原因", example = "申请人临时有事")
    private String reason;

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
