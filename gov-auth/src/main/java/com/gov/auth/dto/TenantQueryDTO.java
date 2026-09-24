package com.gov.auth.dto;

import lombok.Data;

@Data
public class TenantQueryDTO {
    private Integer pageNum = 1;
    private Integer pageSize = 10;
    private String tenantName;
    private Integer status;
}