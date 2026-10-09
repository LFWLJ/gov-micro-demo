package com.gov.application.dto;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * 发起流程请求。
 *
 * <p>原实现直接收 {@code Map<String, Object>}：取出 {@code businessKey}/{@code applicant}，
 * **其余键全部作为流程变量**传入。改成 DTO 后，已知字段显式声明（文档页因此能正常调试），
 * 同时用 {@link JsonAnySetter} 兜住未声明的键，行为与原来完全一致——不会静默丢变量。
 */
@Schema(description = "发起流程请求")
public class ProcessStartDTO {

    @Schema(description = "业务单号", example = "LEAVE-1750000000000")
    private String businessKey;

    @Schema(description = "申请人", example = "ZhangSan")
    private String applicant;

    @Schema(description = "部门负责人（流程节点处理人）", example = "LiSi")
    private String deptLeader;

    @Schema(description = "分管领导", example = "WangWu")
    private String director;

    @Schema(description = "人事", example = "ZhaoLiu")
    private String hr;

    @Schema(description = "请假天数", example = "3")
    private Integer days;

    /** 未显式声明的字段，照旧作为流程变量透传 */
    private final Map<String, Object> extraVariables = new LinkedHashMap<>();

    @JsonAnySetter
    public void putExtraVariable(String key, Object value) {
        extraVariables.put(key, value);
    }

    /** 组装流程变量（等价于原来 body 移除 businessKey/applicant 之后的剩余内容） */
    public Map<String, Object> toVariables() {
        Map<String, Object> variables = new LinkedHashMap<>(extraVariables);
        if (deptLeader != null) variables.put("deptLeader", deptLeader);
        if (director != null) variables.put("director", director);
        if (hr != null) variables.put("hr", hr);
        if (days != null) variables.put("days", days);
        return variables;
    }

    public String getBusinessKey() { return businessKey; }
    public void setBusinessKey(String businessKey) { this.businessKey = businessKey; }
    public String getApplicant() { return applicant; }
    public void setApplicant(String applicant) { this.applicant = applicant; }
    public String getDeptLeader() { return deptLeader; }
    public void setDeptLeader(String deptLeader) { this.deptLeader = deptLeader; }
    public String getDirector() { return director; }
    public void setDirector(String director) { this.director = director; }
    public String getHr() { return hr; }
    public void setHr(String hr) { this.hr = hr; }
    public Integer getDays() { return days; }
    public void setDays(Integer days) { this.days = days; }
}
