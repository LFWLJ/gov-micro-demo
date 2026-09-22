package com.gov.common.log;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import org.mybatis.spring.annotation.MapperScan;

import java.time.LocalDateTime;

@TableName("sys_oper_log")

public class OperLog {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String tenantId;
    private String userId;
    private String module;
    private String operation;
    private String method;
    private String uri;
    private String params;
    private Integer result;
    private String errorMsg;
    private Long costMs;
    private String ip;
    private LocalDateTime createTime;

    // getter / setter 略，按字段名生成即可
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getModule() { return module; }
    public void setModule(String module) { this.module = module; }
    public String getOperation() { return operation; }
    public void setOperation(String operation) { this.operation = operation; }
    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }
    public String getUri() { return uri; }
    public void setUri(String uri) { this.uri = uri; }
    public String getParams() { return params; }
    public void setParams(String params) { this.params = params; }
    public Integer getResult() { return result; }
    public void setResult(Integer result) { this.result = result; }
    public String getErrorMsg() { return errorMsg; }
    public void setErrorMsg(String errorMsg) { this.errorMsg = errorMsg; }
    public Long getCostMs() { return costMs; }
    public void setCostMs(Long costMs) { this.costMs = costMs; }
    public String getIp() { return ip; }
    public void setIp(String ip) { this.ip = ip; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}