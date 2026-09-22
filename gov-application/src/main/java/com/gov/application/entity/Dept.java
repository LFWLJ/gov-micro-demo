package com.gov.application.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@TableName("sys_dept")
public class Dept {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String tenantId;
    private Long parentId;
    private String deptName;
    private Integer orderNum;
    private Integer status;
    private LocalDateTime createTime;

    /** 子部门，不映射数据库 */
    @TableField(exist = false)
    private List<Dept> children = new ArrayList<>();

    // getter / setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public Long getParentId() { return parentId; }
    public void setParentId(Long parentId) { this.parentId = parentId; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public Integer getOrderNum() { return orderNum; }
    public void setOrderNum(Integer orderNum) { this.orderNum = orderNum; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public List<Dept> getChildren() { return children; }
    public void setChildren(List<Dept> children) { this.children = children; }
}