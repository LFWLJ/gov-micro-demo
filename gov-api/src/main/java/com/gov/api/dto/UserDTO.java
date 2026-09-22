package com.gov.api.dto;

public class UserDTO {
    private Long id;
    private String username;
    private String realName;
    private String tenantId;
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