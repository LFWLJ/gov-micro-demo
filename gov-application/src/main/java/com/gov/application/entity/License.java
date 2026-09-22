package com.gov.application.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDate;
import java.time.LocalDateTime;

@TableName("t_license")
public class License {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String tenantId;
    private String licenseNo;
    private String templateCode;
    private String holderName;
    private String holderIdCard;
    private String issueDept;
    private LocalDate issueDate;
    private LocalDate expireDate;
    private String contentJson;
    private String fileUrl;
    private String verifyCode;
    private String status;
    private LocalDateTime createTime;

    // getter / setter 略（按字段名生成）
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public String getLicenseNo() { return licenseNo; }
    public void setLicenseNo(String licenseNo) { this.licenseNo = licenseNo; }
    public String getTemplateCode() { return templateCode; }
    public void setTemplateCode(String templateCode) { this.templateCode = templateCode; }
    public String getHolderName() { return holderName; }
    public void setHolderName(String holderName) { this.holderName = holderName; }
    public String getHolderIdCard() { return holderIdCard; }
    public void setHolderIdCard(String holderIdCard) { this.holderIdCard = holderIdCard; }
    public String getIssueDept() { return issueDept; }
    public void setIssueDept(String issueDept) { this.issueDept = issueDept; }
    public LocalDate getIssueDate() { return issueDate; }
    public void setIssueDate(LocalDate issueDate) { this.issueDate = issueDate; }
    public LocalDate getExpireDate() { return expireDate; }
    public void setExpireDate(LocalDate expireDate) { this.expireDate = expireDate; }
    public String getContentJson() { return contentJson; }
    public void setContentJson(String contentJson) { this.contentJson = contentJson; }
    public String getFileUrl() { return fileUrl; }
    public void setFileUrl(String fileUrl) { this.fileUrl = fileUrl; }
    public String getVerifyCode() { return verifyCode; }
    public void setVerifyCode(String verifyCode) { this.verifyCode = verifyCode; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}