package com.gov.common.redis;

public final class RedisKeys {

    private RedisKeys() {}

    private static final String TOKEN_BLACKLIST = "token:blacklist:%s";
    private static final String USER_CACHE = "user:info:%s";
    private static final String DICT_CACHE = "dict:%s:%s";
    private static final String CONFIG_CACHE = "config:%s:%s";
    private static final String SEQ = "seq:%s";

    public static String tokenBlacklist(String token) {
        return String.format(TOKEN_BLACKLIST, token);
    }

    public static String userCache(String username) {
        return String.format(USER_CACHE, username);
    }

    public static String dictCache(String tenantId, String dictType) {
        return String.format(DICT_CACHE, tenantId, dictType);
    }

    public static String configCache(String tenantId, String key) {
        return String.format(CONFIG_CACHE, tenantId, key);
    }

    public static String seq(String name) {
        return String.format(SEQ, name);
    }
}