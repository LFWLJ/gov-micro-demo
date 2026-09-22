package com.gov.auth.dto;

public class UserSaveDTO {
    private Long id;
    private String username;
    private String password;
    private String realName;
    private String roles;
    private Long deptId;
    private Integer dataScope;
    private Integer status;

    // getter / setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
    public String getRoles() { return roles; }
    public void setRoles(String roles) { this.roles = roles; }
    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public Integer getDataScope() { return dataScope; }
    public void setDataScope(Integer dataScope) { this.dataScope = dataScope; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
}