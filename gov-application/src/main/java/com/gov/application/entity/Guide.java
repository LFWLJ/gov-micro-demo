package com.gov.application.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;

@TableName("t_guide")
public class Guide {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String tenantId;
    private String guideCode;
    private String title;
    private String category;
    private Long deptId;
    private String serviceObject;
    private String legalBasis;
    private String conditions;
    private String materials;
    private String processDesc;
    private Integer legalDays;
    private Integer promiseDays;
    private String chargeStandard;
    private String consultPhone;
    private String onlineUrl;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public String getGuideCode() { return guideCode; }
    public void setGuideCode(String guideCode) { this.guideCode = guideCode; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public String getServiceObject() { return serviceObject; }
    public void setServiceObject(String serviceObject) { this.serviceObject = serviceObject; }
    public String getLegalBasis() { return legalBasis; }
    public void setLegalBasis(String legalBasis) { this.legalBasis = legalBasis; }
    public String getConditions() { return conditions; }
    public void setConditions(String conditions) { this.conditions = conditions; }
    public String getMaterials() { return materials; }
    public void setMaterials(String materials) { this.materials = materials; }
    public String getProcessDesc() { return processDesc; }
    public void setProcessDesc(String processDesc) { this.processDesc = processDesc; }
    public Integer getLegalDays() { return legalDays; }
    public void setLegalDays(Integer legalDays) { this.legalDays = legalDays; }
    public Integer getPromiseDays() { return promiseDays; }
    public void setPromiseDays(Integer promiseDays) { this.promiseDays = promiseDays; }
    public String getChargeStandard() { return chargeStandard; }
    public void setChargeStandard(String chargeStandard) { this.chargeStandard = chargeStandard; }
    public String getConsultPhone() { return consultPhone; }
    public void setConsultPhone(String consultPhone) { this.consultPhone = consultPhone; }
    public String getOnlineUrl() { return onlineUrl; }
    public void setOnlineUrl(String onlineUrl) { this.onlineUrl = onlineUrl; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
}