package com.gov.application.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * 创建事项请求（会自动发起审批流程）。
 */
@Schema(description = "创建事项请求")
public class ApplicationCreateDTO {

    @Schema(description = "事项标题", example = "营业执照办理", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "事项标题不能为空")
    private String title;

    @Schema(description = "申请人", example = "ZhangSan", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "申请人不能为空")
    private String applicant;

    @Schema(description = "部门负责人（流程节点处理人）", example = "LiSi")
    private String deptLeader;

    @Schema(description = "分管领导", example = "WangWu")
    private String director;

    @Schema(description = "人事", example = "ZhaoLiu")
    private String hr;

    @Schema(description = "办理天数", example = "3")
    private Integer days;

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
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
