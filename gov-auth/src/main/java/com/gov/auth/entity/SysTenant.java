package com.gov.auth.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("sys_tenant")
public class SysTenant {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 租户标识，如 tenant_a */
    private String tenantId;

    private String tenantName;

    private String contact;

    private String phone;

    private LocalDate expireDate;

    /** 1启用 0禁用 */
    private Integer status;

    private String remark;

    private LocalDateTime createTime;

    private LocalDateTime updateTime;
}