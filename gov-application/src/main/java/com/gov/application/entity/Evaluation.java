package com.gov.application.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;

@TableName("t_evaluation")
public class Evaluation {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String tenantId;
    private Long applicationId;
    private String businessKey;
    private String evaluator;
    private String evaluatorPhone;
    private Integer score;
    private String content;
    private String channel;
    private Integer isBad;
    private String rectifyStatus;
    private LocalDateTime createTime;

    // getter / setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public Long getApplicationId() { return applicationId; }
    public void setApplicationId(Long applicationId) { this.applicationId = applicationId; }
    public String getBusinessKey() { return businessKey; }
    public void setBusinessKey(String businessKey) { this.businessKey = businessKey; }
    public String getEvaluator() { return evaluator; }
    public void setEvaluator(String evaluator) { this.evaluator = evaluator; }
    public String getEvaluatorPhone() { return evaluatorPhone; }
    public void setEvaluatorPhone(String evaluatorPhone) { this.evaluatorPhone = evaluatorPhone; }
    public Integer getScore() { return score; }
    public void setScore(Integer score) { this.score = score; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getChannel() { return channel; }
    public void setChannel(String channel) { this.channel = channel; }
    public Integer getIsBad() { return isBad; }
    public void setIsBad(Integer isBad) { this.isBad = isBad; }
    public String getRectifyStatus() { return rectifyStatus; }
    public void setRectifyStatus(String rectifyStatus) { this.rectifyStatus = rectifyStatus; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}