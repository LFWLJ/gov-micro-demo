package com.gov.common.redis;

import java.util.concurrent.TimeUnit;

public interface RedisService {

    void set(String key, Object value);

    void set(String key, Object value, long timeout, TimeUnit unit);

    Object get(String key);

    Boolean delete(String key);

    Boolean hasKey(String key);

    Boolean expire(String key, long timeout, TimeUnit unit);

    Long getExpire(String key);

    Long increment(String key, long delta);

    boolean tryLock(String key, String value, long timeoutSeconds);

    boolean releaseLock(String key, String value);
}