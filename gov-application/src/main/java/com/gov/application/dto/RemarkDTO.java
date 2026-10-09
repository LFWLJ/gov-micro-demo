package com.gov.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;

/**
 * 通用备注请求（驳回事项 / 撤回事项共用）。
 *
 * <p>请求体可省略，因此字段不加 {@code @NotBlank}；是否必填由业务语义决定。
 */
@Schema(description = "备注请求")
public class RemarkDTO {

    @Schema(description = "备注/原因", example = "材料不齐，请补充")
    private String remark;

    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
}
