package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.SysDict;
import com.gov.application.entity.SysDictType;
import com.gov.application.mapper.SysDictMapper;
import com.gov.application.mapper.SysDictTypeMapper;
import com.gov.application.service.DictService;
import com.gov.common.exception.BizException;
import com.gov.common.redis.RedisService;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 字典管理实现（含 Redis 缓存）
 * <p>
 * 维护字典类型 ({@link SysDictType}) 和字典项 ({@link SysDict}) 的两级结构。
 * 字典项读取走 Redis 缓存（tenantId:dictType → List），30 分钟过期；
 * 写操作（增删改）完成后立即清除对应缓存，保证数据一致性。
 * </p>
 */
@Service
public class DictServiceImpl implements DictService {

    @Autowired
    private SysDictMapper dictMapper;

    @Autowired
    private SysDictTypeMapper dictTypeMapper;

    @Autowired
    private RedisService redisService;

    private static final String CACHE_PREFIX = "dict:";

    /** 字典类型列表 */
    @Override
    public List<Map<String, Object>> listTypes() {
        List<SysDictType> types = dictTypeMapper.selectList(
                new LambdaQueryWrapper<SysDictType>()
                        .orderByAsc(SysDictType::getId));
        return types.stream().map(t -> {
            Map<String, Object> m = new HashMap<>();
            m.put("dictType", t.getDictType());
            m.put("dictName", t.getDictName());
            m.put("remark", t.getRemark());
            return m;
        }).collect(Collectors.toList());
    }

    /** 按字典类型查询启用状态的字典项（DB 直查，不走缓存） */
    @Override
    public List<SysDict> listByType(String dictType) {
        return dictMapper.selectList(
                new LambdaQueryWrapper<SysDict>()
                        .eq(SysDict::getDictType, dictType)
                        .eq(SysDict::getStatus, 1)
                        .orderByAsc(SysDict::getSort));
    }

    /** 按字典类型查询字典项（带 Redis 缓存，30 分钟过期） */
    @Override
    @SuppressWarnings("unchecked")
    public List<SysDict> listByTypeCached(String dictType) {
        String tenantId = TenantContext.get();
        String cacheKey = CACHE_PREFIX + tenantId + ":" + dictType;

        Object cached = redisService.get(cacheKey);
        if (cached instanceof List) {
            return (List<SysDict>) cached;
        }

        List<SysDict> list = listByType(dictType);
        redisService.set(cacheKey, list, 30, TimeUnit.MINUTES);
        return list;
    }

    /** 创建字典类型（dictType 同租户内唯一） */
    @Override
    public Long createType(SysDictType type) {
        if (!StringUtils.hasText(type.getDictType())) throw new BizException("类型编码不能为空");
        if (!StringUtils.hasText(type.getDictName())) throw new BizException("类型名称不能为空");

        Long exists = dictTypeMapper.selectCount(
                new LambdaQueryWrapper<SysDictType>()
                        .eq(SysDictType::getDictType, type.getDictType()));
        if (exists > 0) throw new BizException("类型编码已存在");

        type.setTenantId(TenantContext.get());
        type.setCreateTime(LocalDateTime.now());
        dictTypeMapper.insert(type);
        return type.getId();
    }

    /** 创建字典项（同类型下 dictValue 唯一），写后清缓存 */
    @Override
    public Long create(SysDict dict) {
        if (!StringUtils.hasText(dict.getDictType())) throw new BizException("字典类型不能为空");
        if (!StringUtils.hasText(dict.getDictLabel())) throw new BizException("字典标签不能为空");
        if (!StringUtils.hasText(dict.getDictValue())) throw new BizException("字典值不能为空");

        Long exists = dictMapper.selectCount(
                new LambdaQueryWrapper<SysDict>()
                        .eq(SysDict::getDictType, dict.getDictType())
                        .eq(SysDict::getDictValue, dict.getDictValue()));
        if (exists > 0) throw new BizException("该类型下字典值已存在");

        dict.setTenantId(TenantContext.get());
        if (dict.getStatus() == null) dict.setStatus(1);
        if (dict.getSort() == null) dict.setSort(0);
        dict.setCreateTime(LocalDateTime.now());
        dictMapper.insert(dict);
        clearCache(dict.getDictType());
        return dict.getId();
    }

    @Override
    public void update(SysDict dict) {
        if (dict.getId() == null) throw new BizException("字典ID不能为空");
        SysDict exist = dictMapper.selectById(dict.getId());
        if (exist == null) throw new BizException("字典不存在");
        dict.setTenantId(exist.getTenantId());
        dictMapper.updateById(dict);
        clearCache(exist.getDictType());
    }

    @Override
    public void delete(Long id) {
        SysDict dict = dictMapper.selectById(id);
        if (dict == null) throw new BizException("字典不存在");
        dictMapper.deleteById(id);
        clearCache(dict.getDictType());
    }

    private void clearCache(String dictType) {
        redisService.delete(CACHE_PREFIX + TenantContext.get() + ":" + dictType);
    }
}