package com.gov.application.dto;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 完成任务请求。
 *
 * <p>原实现直接收 {@code Map<String, Object>} 并整体作为流程变量传入。改成 DTO 后，
 * 常用字段（{@code approved}/{@code comment}）显式声明以便文档页调试，
 * 其余键用 {@link JsonAnySetter} 兜住，仍会作为流程变量透传。
 */
@Schema(description = "完成任务请求（字段将作为流程变量传入）")
public class ProcessCompleteDTO {

    @Schema(description = "是否同意", example = "true")
    private Boolean approved;

    @Schema(description = "审批意见", example = "同意")
    private String comment;

    /** 未显式声明的字段，照旧作为流程变量透传 */
    private final Map<String, Object> extraVariables = new LinkedHashMap<>();

    @JsonAnySetter
    public void putExtraVariable(String key, Object value) {
        extraVariables.put(key, value);
    }

    /** 组装流程变量（与原 Map 入参语义一致） */
    public Map<String, Object> toVariables() {
        Map<String, Object> variables = new LinkedHashMap<>(extraVariables);
        if (approved != null) variables.put("approved", approved);
        if (comment != null) variables.put("comment", comment);
        return variables;
    }

    public Boolean getApproved() { return approved; }
    public void setApproved(Boolean approved) { this.approved = approved; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
}
