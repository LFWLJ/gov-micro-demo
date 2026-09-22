package com.gov.application.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

import java.time.LocalDate;
import java.time.LocalDateTime;

@TableName("t_appointment")
public class Appointment {

    @TableId(type = IdType.AUTO)
    private Long id;
    private String tenantId;
    private String appointmentNo;
    private String guideCode;
    private String guideTitle;
    private String visitorName;
    private String visitorPhone;
    private String visitorIdCard;
    private Long deptId;
    private LocalDate appointDate;
    private String timeSlot;
    private String queueNo;
    private String status;
    private LocalDateTime checkinTime;
    private LocalDateTime finishTime;
    private String cancelReason;
    private String remark;
    private LocalDateTime createTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    public String getAppointmentNo() { return appointmentNo; }
    public void setAppointmentNo(String appointmentNo) { this.appointmentNo = appointmentNo; }
    public String getGuideCode() { return guideCode; }
    public void setGuideCode(String guideCode) { this.guideCode = guideCode; }
    public String getGuideTitle() { return guideTitle; }
    public void setGuideTitle(String guideTitle) { this.guideTitle = guideTitle; }
    public String getVisitorName() { return visitorName; }
    public void setVisitorName(String visitorName) { this.visitorName = visitorName; }
    public String getVisitorPhone() { return visitorPhone; }
    public void setVisitorPhone(String visitorPhone) { this.visitorPhone = visitorPhone; }
    public String getVisitorIdCard() { return visitorIdCard; }
    public void setVisitorIdCard(String visitorIdCard) { this.visitorIdCard = visitorIdCard; }
    public Long getDeptId() { return deptId; }
    public void setDeptId(Long deptId) { this.deptId = deptId; }
    public LocalDate getAppointDate() { return appointDate; }
    public void setAppointDate(LocalDate appointDate) { this.appointDate = appointDate; }
    public String getTimeSlot() { return timeSlot; }
    public void setTimeSlot(String timeSlot) { this.timeSlot = timeSlot; }
    public String getQueueNo() { return queueNo; }
    public void setQueueNo(String queueNo) { this.queueNo = queueNo; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCheckinTime() { return checkinTime; }
    public void setCheckinTime(LocalDateTime checkinTime) { this.checkinTime = checkinTime; }
    public LocalDateTime getFinishTime() { return finishTime; }
    public void setFinishTime(LocalDateTime finishTime) { this.finishTime = finishTime; }
    public String getCancelReason() { return cancelReason; }
    public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
}