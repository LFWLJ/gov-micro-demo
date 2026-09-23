package com.gov.application.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Consult;
import com.gov.application.mapper.ConsultMapper;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Service
public class ConsultService {

    @Autowired
    private ConsultMapper consultMapper;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMdd");

    /**
     * 分页查询
     */
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

    /**
     * 提交工单（工单号动态生成）
     */
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

        consult.setTenantId(TenantContext.get());
        // 生成工单号：CON-yyyyMMdd-序号
        String dateStr = LocalDateTime.now().format(DATE_FMT);
        Long todayCount = consultMapper.selectCount(
                new LambdaQueryWrapper<Consult>()
                        .likeRight(Consult::getConsultNo, "CON-" + dateStr));
        consult.setConsultNo(String.format("CON-%s-%03d", dateStr, todayCount + 1));

        consult.setStatus("PENDING");
        consult.setCreateTime(LocalDateTime.now());
        consultMapper.insert(consult);
        return consult.getId();
    }

    /**
     * 回复工单
     */
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

    /**
     * 关闭工单
     */
    public void close(Long id) {
        Consult consult = consultMapper.selectById(id);
        if (consult == null) {
            throw new BizException("工单不存在");
        }
        consult.setStatus("CLOSED");
        consultMapper.updateById(consult);
    }

    /**
     * 删除
     */
    public void delete(Long id) {
        Consult consult = consultMapper.selectById(id);
        if (consult == null) {
            throw new BizException("工单不存在");
        }
        consultMapper.deleteById(id);
    }

    /**
     * 统计
     */
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