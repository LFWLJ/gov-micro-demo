package com.gov.application.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Appointment;
import com.gov.application.mapper.AppointmentMapper;
import com.gov.common.exception.BizException;
import com.gov.common.redis.RedisService;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
public class AppointmentService {

    @Autowired
    private AppointmentMapper appointmentMapper;

    @Autowired
    private RedisService redisService;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    /**
     * 分页查询
     */
    public Map<String, Object> page(int page, int size, String keyword,
                                    String status, String appointDate) {
        LambdaQueryWrapper<Appointment> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Appointment::getVisitorName, keyword)
                    .or().like(Appointment::getVisitorPhone, keyword)
                    .or().like(Appointment::getAppointmentNo, keyword));
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(Appointment::getStatus, status);
        }
        if (StringUtils.hasText(appointDate)) {
            wrapper.eq(Appointment::getAppointDate, LocalDate.parse(appointDate));
        }
        wrapper.orderByDesc(Appointment::getId);

        Page<Appointment> p = new Page<>(page, size);
        Page<Appointment> result = appointmentMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return data;
    }

    /**
     * 创建预约（Redis 原子生成预约号 + 排队号）
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> create(Appointment appointment) {
        if (!StringUtils.hasText(appointment.getVisitorName())) {
            throw new BizException("预约人姓名不能为空");
        }
        if (!StringUtils.hasText(appointment.getVisitorPhone())) {
            throw new BizException("手机号不能为空");
        }
        if (appointment.getAppointDate() == null) {
            throw new BizException("预约日期不能为空");
        }
        if (appointment.getAppointDate().isBefore(LocalDate.now())) {
            throw new BizException("不能预约过去的日期");
        }

        String tenantId = TenantContext.get();
        appointment.setTenantId(tenantId);

        String dateStr = appointment.getAppointDate().format(DATE_FMT);

        // ★ 用 Redis INCR 原子生成预约号序号
        String apptKey = "seq:appointment:" + tenantId + ":" + dateStr;
        Long apptSeq = nextSeq(apptKey);
        String appointmentNo = String.format("APT-%s-%03d", dateStr, apptSeq);

        // ★ 用 Redis INCR 原子生成排队号序号（按日期）
        String queueKey = "seq:queue:" + tenantId + ":" + dateStr;
        Long queueSeq = nextSeq(queueKey);
        String queueNo = String.format("A%03d", queueSeq);

        appointment.setAppointmentNo(appointmentNo);
        appointment.setQueueNo(queueNo);
        appointment.setStatus("BOOKED");
        appointment.setCreateTime(LocalDateTime.now());
        appointmentMapper.insert(appointment);

        Map<String, Object> result = new HashMap<>();
        result.put("id", appointment.getId());
        result.put("appointmentNo", appointmentNo);
        result.put("queueNo", queueNo);
        return result;
    }

    /**
     * 原子获取下一个序号
     * 第一次创建时设置过期时间为次日凌晨
     */
    private Long nextSeq(String key) {
        Long seq = redisService.increment(key, 1);
        if (seq == null) {
            throw new BizException("生成排队号失败，请重试");
        }
        // 首次生成，设置 TTL 到次日凌晨
        if (seq == 1L) {
            long seconds = Duration.between(
                    LocalDateTime.now(),
                    LocalDateTime.of(LocalDate.now().plusDays(1), LocalTime.MIDNIGHT)
            ).getSeconds();
            if (seconds > 0) {
                redisService.expire(key, seconds, TimeUnit.SECONDS);
            }
        }
        return seq;
    }

    /**
     * 签到
     */
    public void checkin(Long id) {
        Appointment a = appointmentMapper.selectById(id);
        if (a == null) throw new BizException("预约不存在");
        if (!"BOOKED".equals(a.getStatus())) {
            throw new BizException("当前状态不能签到");
        }
        a.setStatus("CHECKED");
        a.setCheckinTime(LocalDateTime.now());
        appointmentMapper.updateById(a);
    }

    /**
     * 办结
     */
    public void finish(Long id) {
        Appointment a = appointmentMapper.selectById(id);
        if (a == null) throw new BizException("预约不存在");
        if (!"CHECKED".equals(a.getStatus())) {
            throw new BizException("请先签到");
        }
        a.setStatus("DONE");
        a.setFinishTime(LocalDateTime.now());
        appointmentMapper.updateById(a);
    }

    /**
     * 取消
     */
    public void cancel(Long id, String reason) {
        Appointment a = appointmentMapper.selectById(id);
        if (a == null) throw new BizException("预约不存在");
        if ("DONE".equals(a.getStatus()) || "CANCELLED".equals(a.getStatus())) {
            throw new BizException("当前状态不能取消");
        }
        a.setStatus("CANCELLED");
        a.setCancelReason(reason);
        appointmentMapper.updateById(a);
    }

    /**
     * 今日排队列表
     */
    public List<Appointment> todayQueue() {
        return appointmentMapper.selectList(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, LocalDate.now())
                        .in(Appointment::getStatus, "BOOKED", "CHECKED")
                        .orderByAsc(Appointment::getQueueNo));
    }

    /**
     * 统计
     */
    public Map<String, Object> stats() {
        LocalDate today = LocalDate.now();
        Map<String, Object> result = new HashMap<>();

        result.put("todayTotal", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)));
        result.put("todayBooked", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)
                        .eq(Appointment::getStatus, "BOOKED")));
        result.put("todayChecked", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)
                        .eq(Appointment::getStatus, "CHECKED")));
        result.put("todayDone", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)
                        .eq(Appointment::getStatus, "DONE")));
        return result;
    }
}