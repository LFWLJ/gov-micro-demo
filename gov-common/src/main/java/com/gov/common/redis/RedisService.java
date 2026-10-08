package com.gov.common.redis;

import java.util.concurrent.TimeUnit;

/**
 * Redis 操作服务接口（门面模式）
 * <p>
 * 对 Spring Data Redis 的 {@code RedisTemplate} 做二次封装，屏蔽底层样板代码，
 * 并额外提供分布式锁能力（基于 SETNX + Lua 解锁，保证原子性）。
 * </p>
 *
 * @see RedisServiceImpl
 * @see RedisKeys
 */
public interface RedisService {

    /** 设置键值对（永久过期） */
    void set(String key, Object value);

    /** 设置带过期时间的键值对 */
    void set(String key, Object value, long timeout, TimeUnit unit);

    /** 获取值，不存在返回 null */
    Object get(String key);

    /** 删除指定 key */
    Boolean delete(String key);

    /** 判断 key 是否存在 */
    Boolean hasKey(String key);

    /** 设置 key 的过期时间 */
    Boolean expire(String key, long timeout, TimeUnit unit);

    /** 获取 key 的剩余过期秒数；-1 表示永久，-2 表示不存在 */
    Long getExpire(String key);

    /**
     * 对数值型 key 进行自增 / 自减
     * <p>
     * 若 key 不存在会先初始化为 0 再自增。常用于计数器场景（如限流窗口、流水号）。
     * </p>
     *
     * @param key   计数器 key
     * @param delta 增量（可传负数实现自减）
     * @return 自增后的最终值
     */
    Long increment(String key, long delta);

    /**
     * 尝试获取分布式锁（SETNX）
     * <p>
     * 底层使用 {@code SET key value NX EX timeout}，原子地完成"不存在则创建并设置过期"。
     * 调用方需保证传入的 {@code value} 是唯一标识（如 UUID），否则可能误删别人的锁。
     * </p>
     *
     * @param key           锁的 key
     * @param value         锁的 value（唯一标识，用于释放时校验所有权）
     * @param timeoutSeconds 锁的持有过期时间（秒），防止死锁
     * @return true = 获取成功，false = 锁已被他人持有
     */
    boolean tryLock(String key, String value, long timeoutSeconds);

    /**
     * 释放分布式锁（Lua 脚本保证原子性）
     * <p>
     * 只有当当前 value 与锁的持有者 value 一致时才执行删除，
     * 避免误删他人在锁过期后重新获取的锁。
     * </p>
     *
     * @param key   锁的 key
     * @param value 调用方持有的唯一标识
     * @return true = 释放成功，false = 释放失败（可能已过期或 value 不匹配）
     */
    boolean releaseLock(String key, String value);
}