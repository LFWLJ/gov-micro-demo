package com.gov.application.dto;

import com.alibaba.excel.annotation.ExcelProperty;
import com.alibaba.excel.annotation.write.style.ColumnWidth;

public class ApplicationExportVO {

    @ExcelProperty("序号")
    @ColumnWidth(8)
    private Integer seq;

    @ExcelProperty("事项标题")
    @ColumnWidth(30)
    private String title;

    @ExcelProperty("申请人")
    @ColumnWidth(15)
    private String applicant;

    @ExcelProperty("部门")
    @ColumnWidth(20)
    private String deptName;

    @ExcelProperty("状态")
    @ColumnWidth(12)
    private String status;

    @ExcelProperty("创建时间")
    @ColumnWidth(22)
    private String createTime;

    // getter / setter
    public Integer getSeq() { return seq; }
    public void setSeq(Integer seq) { this.seq = seq; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getApplicant() { return applicant; }
    public void setApplicant(String applicant) { this.applicant = applicant; }
    public String getDeptName() { return deptName; }
    public void setDeptName(String deptName) { this.deptName = deptName; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }
}