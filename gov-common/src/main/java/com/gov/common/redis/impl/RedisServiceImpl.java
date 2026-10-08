package com.gov.common.redis.impl;

import com.gov.common.redis.RedisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.concurrent.TimeUnit;

/**
 * Redis 服务默认实现
 * <p>
 * 基于 {@link RedisTemplate} 封装常用操作，分布式锁部分额外维护一条 Lua 脚本
 * （{@code UNLOCK_SCRIPT}），保证释放锁时"比较 value + 删除"的原子性。
 * </p>
 *
 * @see RedisService
 */
@Component
public class RedisServiceImpl implements RedisService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    /**
     * 释放锁的 Lua 脚本
     * <p>
     * 先判断 KEYS[1] 当前值是否等于 ARGV[1]（锁持有者的唯一标识），
     * 只有相等时才执行 DEL，防止误删他人在锁过期后重新获取的锁。
     * </p>
     */
    private static final String UNLOCK_SCRIPT =
            "if redis.call('get', KEYS[1]) == ARGV[1] then " +
            "  return redis.call('del', KEYS[1]) " +
            "else " +
            "  return 0 " +
            "end";

    /** Lua 脚本执行器，单例复用 */
    private final DefaultRedisScript<Long> unlockScript =
            new DefaultRedisScript<>(UNLOCK_SCRIPT, Long.class);

    @Override
    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    @Override
    public void set(String key, Object value, long timeout, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    @Override
    public Object get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    @Override
    public Boolean delete(String key) {
        return redisTemplate.delete(key);
    }

    @Override
    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    @Override
    public Boolean expire(String key, long timeout, TimeUnit unit) {
        return redisTemplate.expire(key, timeout, unit);
    }

    @Override
    public Long getExpire(String key) {
        return redisTemplate.getExpire(key);
    }

    @Override
    public Long increment(String key, long delta) {
        return redisTemplate.opsForValue().increment(key, delta);
    }

    /**
     * 尝试获取分布式锁
     * <p>底层等价于 Redis 命令：{@code SET key value NX EX timeout}</p>
     */
    @Override
    public boolean tryLock(String key, String value, long timeoutSeconds) {
        Boolean ok = redisTemplate.opsForValue()
                .setIfAbsent(key, value, timeoutSeconds, TimeUnit.SECONDS);
        return Boolean.TRUE.equals(ok);
    }

    /**
     * 使用 Lua 脚本原子释放分布式锁
     * <p>返回值 1 = 释放成功，0 = 释放失败（value 不匹配或 key 已不存在）</p>
     */
    @Override
    public boolean releaseLock(String key, String value) {
        Long result = redisTemplate.execute(unlockScript,
                Collections.singletonList(key), value);
        return result != null && result == 1L;
    }
}