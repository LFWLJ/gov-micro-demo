package com.gov.auth.dto;

import lombok.Data;

/**
 * 租户分页查询参数
 * <p>
 * 配合 MyBatis-Plus 的 {@code Page} + {@code LambdaQueryWrapper} 使用，
 * 支持按租户名称模糊搜索和状态精确过滤。
 * </p>
 */
@Data
public class TenantQueryDTO {

    /** 页码，默认 1 */
    private Integer pageNum = 1;
    /** 每页条数，默认 10 */
    private Integer pageSize = 10;
    /** 租户名称（模糊匹配） */
    private String tenantName;
    /** 租户状态：1=启用，0=禁用 */
    private Integer status;
}