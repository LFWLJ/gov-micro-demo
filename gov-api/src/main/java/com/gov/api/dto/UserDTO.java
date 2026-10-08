package com.gov.api.dto;

/**
 * 用户信息 DTO（跨服务传输用）
 * <p>
 * auth 服务通过 {@link com.gov.api.feign.AuthFeignClient} 将用户基本信息
 * 返回给其他微服务时使用本类。字段刻意精简，只保留各业务服务真正需要的属性，
 * 避免把完整的 {@code SysUser} 实体（含密码、创建时间等敏感/冗余字段）暴露出去。
 * </p>
 */
public class UserDTO {

    /** 用户主键 ID */
    private Long id;
    /** 登录用户名（唯一） */
    private String username;
    /** 真实姓名 */
    private String realName;
    /** 所属租户 ID */
    private String tenantId;
    /** 角色标识，多个用逗号分隔（如 {@code ROLE_ADMIN,ROLE_USER}） */
    private String roles;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public String getRoles() { return roles; }
    public void setRoles(String roles) { this.roles = roles; }
}