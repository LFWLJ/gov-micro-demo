package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.dto.BatchAddDTO;
import com.gov.application.dto.SensitiveWordQueryDTO;
import com.gov.application.entity.SensitiveWord;
import com.gov.application.mapper.SensitiveWordMapper;
import com.gov.application.service.SensitiveWordService;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 敏感词管理实现
 * <p>
 * 提供敏感词的 CRUD + 批量导入能力。
 * 同租户内敏感词唯一（依赖 MyBatis-Plus 租户插件自动拼 tenant_id），
 * 批量导入时先查已存在集合，避免逐条唯一键冲突导致插入中断。
 * </p>
 */
@Service
public class SensitiveWordServiceImpl implements SensitiveWordService {

    @Resource
    private SensitiveWordMapper sensitiveWordMapper;

    /** 分页查询敏感词，支持按关键词模糊搜 + 分类精确过滤 */
    @Override
    public IPage<SensitiveWord> pageWords(SensitiveWordQueryDTO query) {
        LambdaQueryWrapper<SensitiveWord> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.hasText(query.getWord()), SensitiveWord::getWord, query.getWord());
        qw.eq(StringUtils.hasText(query.getCategory()), SensitiveWord::getCategory, query.getCategory());
        qw.orderByDesc(SensitiveWord::getId);
        int pageNum = query.getPageNum() == null ? 1 : query.getPageNum();
        int pageSize = query.getPageSize() == null ? 10 : query.getPageSize();
        return sensitiveWordMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    /** 新增敏感词，trim 后同租户内唯一校验 */
    @Override
    public void addWord(SensitiveWord word) {
        if (!StringUtils.hasText(word.getWord())) {
            throw new BizException("敏感词不能为空");
        }
        String trimWord = word.getWord().trim();
        // 同租户内唯一（多租户插件会自动拼 tenant_id）
        Long cnt = sensitiveWordMapper.selectCount(
                new LambdaQueryWrapper<SensitiveWord>()
                        .eq(SensitiveWord::getWord, trimWord));
        if (cnt != null && cnt > 0) {
            throw new BizException("敏感词已存在：" + trimWord);
        }
        word.setWord(trimWord);
        // 多租户插件会自动填 tenant_id，但为了保险手动也设一次
        if (!StringUtils.hasText(word.getTenantId())) {
            word.setTenantId(TenantContext.get());
        }
        sensitiveWordMapper.insert(word);
    }

    /** 更新敏感词，不允许修改 tenantId */
    @Override
    public void updateWord(SensitiveWord word) {
        if (word.getId() == null) throw new BizException("ID不能为空");
        SensitiveWord db = sensitiveWordMapper.selectById(word.getId());
        if (db == null) throw new BizException("敏感词不存在");

        if (StringUtils.hasText(word.getWord())) {
            String trimWord = word.getWord().trim();
            if (!trimWord.equals(db.getWord())) {
                Long cnt = sensitiveWordMapper.selectCount(
                        new LambdaQueryWrapper<SensitiveWord>()
                                .eq(SensitiveWord::getWord, trimWord)
                                .ne(SensitiveWord::getId, word.getId()));
                if (cnt != null && cnt > 0) {
                    throw new BizException("敏感词已存在：" + trimWord);
                }
            }
            word.setWord(trimWord);
        }
        // 不允许改 tenantId
        word.setTenantId(null);
        sensitiveWordMapper.updateById(word);
    }

    /** 删除敏感词 */
    @Override
    public void deleteWord(Long id) {
        if (id == null) throw new BizException("ID不能为空");
        SensitiveWord db = sensitiveWordMapper.selectById(id);
        if (db == null) throw new BizException("敏感词不存在");
        sensitiveWordMapper.deleteById(id);
    }

    /**
     * 批量导入敏感词
     * <p>
     * 执行步骤：
     * <ol>
     *     <li>输入去重 + 去空白</li>
     *     <li>一次查询同租户已存在的敏感词集合</li>
     *     <li>只插入不存在的，忽略唯一键冲突</li>
     * </ol>
     * 返回实际新增条数。
     * </p>
     */
    @Override
    public int batchAdd(BatchAddDTO dto) {
        if (dto == null || CollectionUtils.isEmpty(dto.getWords())) {
            throw new BizException("待导入的敏感词不能为空");
        }
        String tenantId = TenantContext.get();
        if (!StringUtils.hasText(tenantId)) {
            throw new BizException("缺少租户标识");
        }

        // 去重 + 去空白
        Set<String> uniqueWords = new HashSet<>();
        for (String w : dto.getWords()) {
            if (StringUtils.hasText(w)) {
                uniqueWords.add(w.trim());
            }
        }
        if (uniqueWords.isEmpty()) {
            throw new BizException("没有有效的敏感词");
        }

        // 查已存在的，避免唯一键冲突
        List<SensitiveWord> existList = sensitiveWordMapper.selectList(
                new LambdaQueryWrapper<SensitiveWord>()
                        .in(SensitiveWord::getWord, uniqueWords));
        Set<String> existSet = new HashSet<>();
        for (SensitiveWord w : existList) {
            existSet.add(w.getWord());
        }

        int count = 0;
        for (String w : uniqueWords) {
            if (existSet.contains(w)) continue;
            SensitiveWord entity = new SensitiveWord();
            entity.setTenantId(tenantId);
            entity.setWord(w);
            entity.setCategory(dto.getCategory());
            try {
                sensitiveWordMapper.insert(entity);
                count++;
            } catch (Exception e) {
                // 唯一键冲突就跳过
            }
        }
        return count;
    }
}