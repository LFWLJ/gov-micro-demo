package com.gov.application.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;

@TableName("t_evaluation_rectify")
public class Rectify {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String tenantId;
    private Long evaluationId;
    private String rectifier;
    private String rectifyContent;
    private LocalDateTime rectifyTime;
    private String status;
    private LocalDateTime createTime;

    // getter / setter 略
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public Long getEvaluationId() { return evaluationId; }
    public void setEvaluationId(Long evaluationId) { this.evaluationId = evaluationId; }
    public String getRectifier() { return rectifier; }
    public void setRectifier(String rectifier) { this.rectifier = rectifier; }
    public String getRectifyContent() { return rectifyContent; }
    public void setRectifyContent(String rectifyContent) { this.rectifyContent = rectifyContent; }
    public LocalDateTime getRectifyTime() { return rectifyTime; }
    public void setRectifyTime(LocalDateTime rectifyTime) { this.rectifyTime = rectifyTime; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}