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

/**
 * 办件评价与整改业务实现
 * <p>
 * 提供市民对办件的 1~5 星评价、差评整改闭环、评价统计看板：
 * <ul>
 *     <li><b>评价提交</b>：score 1~2 自动标记为差评 (isBad=1)，整改状态置 PENDING；
 *         score 3~5 为好评，整改状态 NONE。</li>
 *     <li><b>整改</b>：仅对差评开放，整改完成后写整改记录 (Rectify) 并回写评价的 rectifyStatus。</li>
 *     <li><b>统计</b>：总分、好评数、差评数、待整改数、好评率、平均分。</li>
 * </ul>
 * </p>
 */
@Service
public class EvaluationServiceImpl implements EvaluationService {

    @Autowired
    private EvaluationMapper evaluationMapper;

    @Autowired
    private RectifyMapper rectifyMapper;

    /** 分页查询评价列表，支持按评分/是否差评/整改状态过滤 */
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

    /** 提交评价（1~5 星），score ≤ 2 自动标记为差评 */
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

    /**
     * 对差评进行整改（事务内）
     * <p>
     * 写入 Rectify 整改记录 + 回写 Evaluation.rectifyStatus = DONE。
     * 仅允许对未整改的差评操作。
     * </p>
     */
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

    /** 评价统计看板：总数、好评数、差评数、待整改数、好评率、平均分 */
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