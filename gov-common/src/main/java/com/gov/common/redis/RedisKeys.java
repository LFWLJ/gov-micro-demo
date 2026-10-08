package com.gov.common.redis;

/**
 * Redis Key 前缀常量工具类
 * <p>
 * 项目内所有 Redis Key 必须通过本类的静态方法构造，统一采用
 * {@code 业务:功能[:参数]} 的冒号分段格式，便于人工阅读和批量清理。
 * </p>
 *
 * <p>Key 规范：</p>
 * <ul>
 *   <li>{@code token:blacklist:{token}} — Token 黑名单（JWT 注销场景）</li>
 *   <li>{@code user:info:{username}} — 用户信息缓存</li>
 *   <li>{@code dict:{tenantId}:{dictType}} — 字典缓存</li>
 *   <li>{@code config:{tenantId}:{key}} — 系统配置缓存</li>
 *   <li>{@code seq:{name}} — 流水号 / 序号计数器</li>
 * </ul>
 */
public final class RedisKeys {

    private RedisKeys() {}

    /** Token 黑名单，参数为 token 字符串 */
    private static final String TOKEN_BLACKLIST = "token:blacklist:%s";
    /** 用户信息缓存，参数为用户名 */
    private static final String USER_CACHE = "user:info:%s";
    /** 字典缓存，参数依次为 tenantId、dictType */
    private static final String DICT_CACHE = "dict:%s:%s";
    /** 系统配置缓存，参数依次为 tenantId、配置键 */
    private static final String CONFIG_CACHE = "config:%s:%s";
    /** 序号计数器，参数为序号名称 */
    private static final String SEQ = "seq:%s";

    /** 构造 Token 黑名单 Key */
    public static String tokenBlacklist(String token) {
        return String.format(TOKEN_BLACKLIST, token);
    }

    /** 构造用户信息缓存 Key */
    public static String userCache(String username) {
        return String.format(USER_CACHE, username);
    }

    /** 构造字典缓存 Key */
    public static String dictCache(String tenantId, String dictType) {
        return String.format(DICT_CACHE, tenantId, dictType);
    }

    /** 构造系统配置缓存 Key */
    public static String configCache(String tenantId, String key) {
        return String.format(CONFIG_CACHE, tenantId, key);
    }

    /** 构造序号计数器 Key */
    public static String seq(String name) {
        return String.format(SEQ, name);
    }
}