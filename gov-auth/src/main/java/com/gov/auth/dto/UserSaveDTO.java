package com.gov.auth.dto;

/**
 * 用户新增/编辑请求 DTO
 * <p>
 * 用于 auth 服务的用户管理接口。新增时 {@code id} 为 null，
 * 编辑时 {@code password} 可传 null 表示不修改密码。
 * </p>
 */
public class UserSaveDTO {

    /** 用户 ID，新增时为 null */
    private Long id;
    /** 登录用户名（同租户内唯一） */
    private String username;
    /** 明文密码，新增时必填；编辑时传 null 表示不修改 */
    private String password;
    /** 真实姓名 */
    private String realName;
    /** 角色标识，多个用逗号分隔 */
    private String roles;
    /** 所属部门 ID */
    private Long deptId;
    /** 数据权限范围：1=全部数据，2=本部门及以下，3=仅本部门，4=仅本人 */
    private Integer dataScope;
    /** 状态：1=启用，0=禁用 */
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