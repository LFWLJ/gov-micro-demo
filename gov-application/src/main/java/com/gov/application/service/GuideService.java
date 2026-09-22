package com.gov.application.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Guide;
import com.gov.application.mapper.GuideMapper;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class GuideService {

    @Autowired
    private GuideMapper guideMapper;

    /**
     * 分页查询
     */
    public Map<String, Object> page(int page, int size, String keyword, String category) {
        LambdaQueryWrapper<Guide> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(Guide::getTitle, keyword)
                    .or().like(Guide::getGuideCode, keyword));
        }
        if (StringUtils.hasText(category)) {
            wrapper.eq(Guide::getCategory, category);
        }
        wrapper.orderByDesc(Guide::getId);

        Page<Guide> p = new Page<>(page, size);
        Page<Guide> result = guideMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return data;
    }

    /**
     * 查询所有分类
     */
    public List<String> listCategories() {
        return guideMapper.selectList(null).stream()
                .map(Guide::getCategory)
                .filter(StringUtils::hasText)
                .distinct()
                .sorted()
                .collect(Collectors.toList());
    }

    /**
     * 按ID查询
     */
    public Guide getById(Long id) {
        return guideMapper.selectById(id);
    }

    /**
     * 新增
     */
    public Long create(Guide guide) {
        if (!StringUtils.hasText(guide.getTitle())) throw new BizException("事项名称不能为空");
        if (!StringUtils.hasText(guide.getGuideCode())) throw new BizException("指南编码不能为空");

        Long exists = guideMapper.selectCount(
                new LambdaQueryWrapper<Guide>()
                        .eq(Guide::getGuideCode, guide.getGuideCode()));
        if (exists > 0) throw new BizException("指南编码已存在");

        guide.setTenantId(TenantContext.get());
        if (guide.getStatus() == null) guide.setStatus(1);
        guide.setCreateTime(LocalDateTime.now());
        guideMapper.insert(guide);
        return guide.getId();
    }

    /**
     * 修改
     */
    public void update(Guide guide) {
        if (guide.getId() == null) throw new BizException("ID不能为空");
        Guide exist = guideMapper.selectById(guide.getId());
        if (exist == null) throw new BizException("指南不存在");
        guide.setTenantId(exist.getTenantId());
        guideMapper.updateById(guide);
    }

    /**
     * 删除
     */
    public void delete(Long id) {
        Guide guide = guideMapper.selectById(id);
        if (guide == null) throw new BizException("指南不存在");
        guideMapper.deleteById(id);
    }

    /**
     * 启用/停用
     */
    public void toggleStatus(Long id, Integer status) {
        Guide guide = guideMapper.selectById(id);
        if (guide == null) throw new BizException("指南不存在");
        guide.setStatus(status);
        guideMapper.updateById(guide);
    }
}