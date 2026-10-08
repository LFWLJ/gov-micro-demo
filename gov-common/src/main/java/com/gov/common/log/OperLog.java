package com.gov.common.log;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import org.mybatis.spring.annotation.MapperScan;

import java.time.LocalDateTime;

/**
 * 操作日志实体，对应数据库表 {@code sys_oper_log}
 * <p>
 * 由 {@link OperLogAspect} 在运行时自动填充，业务方通过在 Controller 方法上标注
 * {@link OpLog} 注解即可接入，无需手动 new 并保存。
 * </p>
 *
 * @see OpLog
 * @see OperLogAspect
 */
@TableName("sys_oper_log")

public class OperLog {

    /** 主键，自增 */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 租户标识（多租户隔离），由网关请求头 X-Tenant-Id 注入 */
    private String tenantId;

    /** 操作用户 ID，由网关请求头 X-User-Id 注入 */
    private String userId;

    /** 业务模块名，如"角色管理"、"事项办理" */
    private String module;

    /** 操作描述，如"新增角色"、"提交审批" */
    private String operation;

    /** HTTP 请求方法（GET / POST / PUT / DELETE） */
    private String method;

    /** 请求 URI，如 /api/role/add */
    private String uri;

    /** 请求参数（JSON 字符串，敏感字段已脱敏，超长截断 2000 字符） */
    private String params;

    /** 操作结果：1 = 成功，0 = 失败（抛异常） */
    private Integer result;

    /** 失败时的错误信息（异常 message，最多保留 500 字符） */
    private String errorMsg;

    /** 接口耗时（毫秒） */
    private Long costMs;

    /** 客户端真实 IP（兼容 X-Forwarded-For 等代理头） */
    private String ip;

    /** 日志记录时间 */
    private LocalDateTime createTime;

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