package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Appointment;
import com.gov.application.mapper.AppointmentMapper;
import com.gov.application.service.AppointmentService;
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

/**
 * 预约服务实现
 * <p>
 * 提供政务大厅的在线预约、签到、办理完成、取消等全流程管理。
 * 预约号和排队号使用 Redis 原子自增生成，确保并发下不重复。
 * </p>
 *
 * <h3>状态流转</h3>
 * <pre>
 * BOOKED（已预约）→ CHECKED（已签到）→ DONE（已完成）
 * BOOKED/CHECKED → CANCELLED（已取消）
 * </pre>
 *
 * <h3>编号规则</h3>
 * <ul>
 *     <li>预约号：{@code APT-yyyyMMdd-NNN}（按租户+日期序号，跨天自动重置）</li>
 *     <li>排队号：{@code ANNN}（按租户+日期序号，跨天自动重置）</li>
 * </ul>
 */
@Service
public class AppointmentServiceImpl implements AppointmentService {

    @Autowired
    private AppointmentMapper appointmentMapper;

    @Autowired
    private RedisService redisService;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    /**
     * 分页查询预约列表
     * <p>
     * 支持按预约人姓名、手机号、预约号模糊搜索，按状态和预约日期筛选。
     * 自动受租户拦截器保护。
     * </p>
     */
    @Override
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
     * 创建预约
     * <p>
     * 校验通过后，使用 Redis INCR 原子生成预约号和排队号的序号部分，
     * 当天首次生成时设置过期时间到次日零点，确保跨天自动重置。
     * </p>
     *
     * @return 包含预约号、排队号、记录 ID 的 Map
     */
    @Override
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

        // 生成预约号序号：seq:appointment:{tenantId}:{yyyyMMdd}
        String apptKey = "seq:appointment:" + tenantId + ":" + dateStr;
        Long apptSeq = nextSeq(apptKey);
        String appointmentNo = String.format("APT-%s-%03d", dateStr, apptSeq);

        // 生成排队号序号：seq:queue:{tenantId}:{yyyyMMdd}
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
     * 获取下一个序号（Redis 原子自增）
     * <p>
     * 首次使用某个 key 时（返回 seq=1），设置过期时间到次日零点，
     * 这样第二天该 key 自动消失，序号从 1 重新开始。
     * </p>
     */
    private Long nextSeq(String key) {
        Long seq = redisService.increment(key, 1);
        if (seq == null) {
            throw new BizException("生成排队号失败，请重试");
        }
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

    /** 预约签到，状态从 BOOKED → CHECKED，同时记录签到时间 */
    @Override
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

    /** 办理完成，状态从 CHECKED → DONE，同时记录完成时间 */
    @Override
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

    /** 取消预约，BOOKED/CHECKED 均可取消，已完成或已取消的不能再取消 */
    @Override
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

    /** 查询当天尚未完成/取消的预约队列，按排队号升序排列 */
    @Override
    public List<Appointment> todayQueue() {
        return appointmentMapper.selectList(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, LocalDate.now())
                        .in(Appointment::getStatus, "BOOKED", "CHECKED")
                        .orderByAsc(Appointment::getQueueNo));
    }

    /** 获取今日预约统计数据（总数/已预约/已签到/已完成） */
    @Override
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