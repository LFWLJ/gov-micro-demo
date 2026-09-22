package com.gov.common.redis;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class RedisService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    // ---------- String 操作 ----------

    public void set(String key, Object value) {
        redisTemplate.opsForValue().set(key, value);
    }

    public void set(String key, Object value, long timeout, TimeUnit unit) {
        redisTemplate.opsForValue().set(key, value, timeout, unit);
    }

    public Object get(String key) {
        return redisTemplate.opsForValue().get(key);
    }

    public Boolean delete(String key) {
        return redisTemplate.delete(key);
    }

    public Boolean hasKey(String key) {
        return redisTemplate.hasKey(key);
    }

    public Boolean expire(String key, long timeout, TimeUnit unit) {
        return redisTemplate.expire(key, timeout, unit);
    }

    public Long getExpire(String key) {
        return redisTemplate.getExpire(key);
    }

    // ---------- 原子递增（用于计数器、限流） ----------

    public Long increment(String key, long delta) {
        return redisTemplate.opsForValue().increment(key, delta);
    }

    // ---------- 分布式锁（简单版） ----------

    /**
     * 尝试加锁
     * @return true 表示抢到锁
     */
    public boolean tryLock(String key, String value, long timeoutSeconds) {
        Boolean ok = redisTemplate.opsForValue()
                .setIfAbsent(key, value, timeoutSeconds, TimeUnit.SECONDS);
        return Boolean.TRUE.equals(ok);
    }

    /**
     * 释放锁（只有持有者能释放）
     */
    public boolean releaseLock(String key, String value) {
        Object current = redisTemplate.opsForValue().get(key);
        if (value.equals(current)) {
            return Boolean.TRUE.equals(redisTemplate.delete(key));
        }
        return false;
    }
}