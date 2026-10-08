package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.SysConfig;
import com.gov.application.mapper.SysConfigMapper;
import com.gov.application.service.ConfigService;
import com.gov.common.exception.BizException;
import com.gov.common.redis.RedisService;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * 系统配置管理实现（含 Redis 缓存）
 * <p>
 * KV 型配置项管理，configKey 同租户内唯一。
 * 读取走 Redis 缓存（tenantId:configKey → value），30 分钟过期；
 * 写操作完成后立即清缓存。
 * </p>
 */
@Service
public class ConfigServiceImpl implements ConfigService {

    @Autowired
    private SysConfigMapper configMapper;

    @Autowired
    private RedisService redisService;

    private static final String CACHE_PREFIX = "config:";

    /** 查询配置列表，支持按 configKey 关键词搜索 */
    @Override
    public List<SysConfig> list(String keyword) {
        LambdaQueryWrapper<SysConfig> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.like(SysConfig::getConfigKey, keyword);
        }
        wrapper.orderByAsc(SysConfig::getId);
        return configMapper.selectList(wrapper);
    }

    /** 按 configKey 获取配置值（带 Redis 缓存，30 分钟过期） */
    @Override
    public String getValue(String key) {
        String tenantId = TenantContext.get();
        String cacheKey = CACHE_PREFIX + tenantId + ":" + key;

        Object cached = redisService.get(cacheKey);
        if (cached instanceof String) {
            return (String) cached;
        }

        SysConfig cfg = configMapper.selectOne(
                new LambdaQueryWrapper<SysConfig>()
                        .eq(SysConfig::getConfigKey, key));
        String value = cfg == null ? null : cfg.getConfigValue();
        if (value != null) {
            redisService.set(cacheKey, value, 30, TimeUnit.MINUTES);
        }
        return value;
    }

    @Override
    public Long create(SysConfig config) {
        if (!StringUtils.hasText(config.getConfigKey())) {
            throw new BizException("配置键不能为空");
        }
        Long exists = configMapper.selectCount(
                new LambdaQueryWrapper<SysConfig>()
                        .eq(SysConfig::getConfigKey, config.getConfigKey()));
        if (exists > 0) throw new BizException("配置键已存在");

        config.setTenantId(TenantContext.get());
        config.setCreateTime(LocalDateTime.now());
        configMapper.insert(config);
        clearCache(config.getConfigKey());
        return config.getId();
    }

    @Override
    public void update(SysConfig config) {
        if (config.getId() == null) throw new BizException("配置ID不能为空");
        SysConfig exist = configMapper.selectById(config.getId());
        if (exist == null) throw new BizException("配置不存在");
        config.setTenantId(exist.getTenantId());
        configMapper.updateById(config);
        clearCache(exist.getConfigKey());
    }

    @Override
    public void delete(Long id) {
        SysConfig config = configMapper.selectById(id);
        if (config == null) throw new BizException("配置不存在");
        configMapper.deleteById(id);
        clearCache(config.getConfigKey());
    }

    private void clearCache(String key) {
        redisService.delete(CACHE_PREFIX + TenantContext.get() + ":" + key);
    }
}