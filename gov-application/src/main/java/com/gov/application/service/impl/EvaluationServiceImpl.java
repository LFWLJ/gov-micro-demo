package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Evaluation;
import com.gov.application.entity.Rectify;
import com.gov.application.mapper.EvaluationMapper;
import com.gov.application.mapper.RectifyMapper;
import com.gov.application.service.EvaluationService;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
public class EvaluationServiceImpl implements EvaluationService {

    @Autowired
    private EvaluationMapper evaluationMapper;

    @Autowired
    private RectifyMapper rectifyMapper;

    @Override
    public Map<String, Object> page(int page, int size, Integer score,
                                    Integer isBad, String rectifyStatus) {
        LambdaQueryWrapper<Evaluation> wrapper = new LambdaQueryWrapper<>();
        if (score != null) {
            wrapper.eq(Evaluation::getScore, score);
        }
        if (isBad != null) {
            wrapper.eq(Evaluation::getIsBad, isBad);
        }
        if (StringUtils.hasText(rectifyStatus)) {
            wrapper.eq(Evaluation::getRectifyStatus, rectifyStatus);
        }
        wrapper.orderByDesc(Evaluation::getId);

        Page<Evaluation> p = new Page<>(page, size);
        Page<Evaluation> result = evaluationMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return data;
    }

    @Override
    public Long submit(Evaluation eval) {
        if (eval.getScore() == null || eval.getScore() < 1 || eval.getScore() > 5) {
            throw new BizException("评分必须在 1~5 之间");
        }
        eval.setTenantId(TenantContext.get());
        eval.setIsBad(eval.getScore() <= 2 ? 1 : 0);
        eval.setRectifyStatus(eval.getIsBad() == 1 ? "PENDING" : "NONE");
        eval.setCreateTime(LocalDateTime.now());
        evaluationMapper.insert(eval);
        return eval.getId();
    }

    @Override
    @Transactional
    public void rectify(Long evaluationId, String content) {
        Evaluation eval = evaluationMapper.selectById(evaluationId);
        if (eval == null) {
            throw new BizException("评价不存在");
        }
        if (eval.getIsBad() != 1) {
            throw new BizException("只有差评才需要整改");
        }
        if ("DONE".equals(eval.getRectifyStatus())) {
            throw new BizException("该评价已整改");
        }
        if (!StringUtils.hasText(content)) {
            throw new BizException("整改内容不能为空");
        }

        Rectify r = new Rectify();
        r.setTenantId(TenantContext.get());
        r.setEvaluationId(evaluationId);
        r.setRectifyContent(content);
        r.setRectifyTime(LocalDateTime.now());
        r.setStatus("DONE");
        r.setCreateTime(LocalDateTime.now());
        rectifyMapper.insert(r);

        eval.setRectifyStatus("DONE");
        evaluationMapper.updateById(eval);
    }

    @Override
    public Map<String, Object> stats() {
        Long total = evaluationMapper.selectCount(null);
        Long goodCount = evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>().ge(Evaluation::getScore, 4));
        Long badCount = evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>().eq(Evaluation::getIsBad, 1));
        Long pendingRectify = evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>().eq(Evaluation::getRectifyStatus, "PENDING"));

        Double avgScore = 0.0;
        if (total > 0) {
            avgScore = evaluationMapper.selectList(null).stream()
                    .mapToInt(Evaluation::getScore)
                    .average().orElse(0);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("total", total);
        result.put("goodCount", goodCount);
        result.put("badCount", badCount);
        result.put("pendingRectify", pendingRectify);
        result.put("goodRate", total == 0 ? 0 : Math.round(goodCount * 100.0 / total));
        result.put("avgScore", Math.round(avgScore * 10) / 10.0);
        return result;
    }
}