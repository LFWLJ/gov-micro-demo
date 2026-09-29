package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Consult;
import com.gov.application.mapper.ConsultMapper;
import com.gov.application.service.ConsultService;
import com.gov.common.exception.BizException;
import com.gov.common.redis.RedisService;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Service
public class ConsultServiceImpl implements ConsultService {

    @Autowired
    private ConsultMapper consultMapper;

    @Autowired
    private RedisService redisService;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    @Override
    public Map<String, Object> page(int page, int size, String keyword,
                                    String type, String status) {
        LambdaQueryWrapper<Consult> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Consult::getTitle, keyword)
                    .or().like(Consult::getContactName, keyword)
                    .or().like(Consult::getConsultNo, keyword));
        }
        if (StringUtils.hasText(type)) {
            wrapper.eq(Consult::getType, type);
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(Consult::getStatus, status);
        }
        wrapper.orderByDesc(Consult::getId);

        Page<Consult> p = new Page<>(page, size);
        Page<Consult> result = consultMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return data;
    }

    @Override
    public Long create(Consult consult) {
        if (!StringUtils.hasText(consult.getTitle())) {
            throw new BizException("标题不能为空");
        }
        if (!StringUtils.hasText(consult.getContent())) {
            throw new BizException("内容不能为空");
        }
        if (!StringUtils.hasText(consult.getType())) {
            consult.setType("CONSULT");
        }

        String tenantId = TenantContext.get();
        if (!StringUtils.hasText(tenantId)) {
            throw new BizException("缺少租户标识");
        }
        consult.setTenantId(tenantId);
        String dateStr = LocalDateTime.now().format(DATE_FMT);
        // ★ 用 Redis 原子自增生成当日流水号。
        //   原实现是 count+1，并发提交必然重号（且 consult_no 无唯一索引兜底）；
        //   这里与 AppointmentServiceImpl 的排队号方案保持一致。
        long seq = nextDailySeq("consult:no:" + tenantId + ":" + dateStr);
        consult.setConsultNo(String.format("CON-%s-%03d", dateStr, seq));

        consult.setStatus("PENDING");
        consult.setCreateTime(LocalDateTime.now());
        consultMapper.insert(consult);
        return consult.getId();
    }

    /** 当日流水号：首次自增时把 key 的过期时间设到当天 24 点 */
    private long nextDailySeq(String key) {
        Long seq = redisService.increment(key, 1);
        if (seq == null) {
            throw new BizException("生成工单编号失败，请重试");
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

    @Override
    public void reply(Long id, String handler, String reply) {
        if (!StringUtils.hasText(reply)) {
            throw new BizException("回复内容不能为空");
        }
        Consult consult = consultMapper.selectById(id);
        if (consult == null) {
            throw new BizException("工单不存在");
        }
        if ("DONE".equals(consult.getStatus()) || "CLOSED".equals(consult.getStatus())) {
            throw new BizException("工单已办结，不能重复回复");
        }

        consult.setHandler(handler);
        consult.setReply(reply);
        consult.setReplyTime(LocalDateTime.now());
        consult.setStatus("DONE");
        consultMapper.updateById(consult);
    }

    @Override
    public void close(Long id) {
        Consult consult = consultMapper.selectById(id);
        if (consult == null) {
            throw new BizException("工单不存在");
        }
        consult.setStatus("CLOSED");
        consultMapper.updateById(consult);
    }

    @Override
    public void delete(Long id) {
        Consult consult = consultMapper.selectById(id);
        if (consult == null) {
            throw new BizException("工单不存在");
        }
        consultMapper.deleteById(id);
    }

    @Override
    public Map<String, Object> stats() {
        Map<String, Object> result = new HashMap<>();
        result.put("total", consultMapper.selectCount(null));
        result.put("pending", consultMapper.selectCount(
                new LambdaQueryWrapper<Consult>().eq(Consult::getStatus, "PENDING")));
        result.put("processing", consultMapper.selectCount(
                new LambdaQueryWrapper<Consult>().eq(Consult::getStatus, "PROCESSING")));
        result.put("done", consultMapper.selectCount(
                new LambdaQueryWrapper<Consult>().eq(Consult::getStatus, "DONE")));
        return result;
    }
}