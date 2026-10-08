package com.gov.auth.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * JWT 令牌工具类
 * <p>
 * 基于 JJWT 库封装 Token 的签发与解析，使用 HMAC-SHA 对称签名。
 * 签名密钥通过配置项 {@code gov.jwt.secret} 注入，auth 服务与 gateway 必须保持一致。
 * </p>
 *
 * <h3>Token 载荷结构</h3>
 * <ul>
 *     <li>{@code uid} - 用户 ID</li>
 *     <li>{@code tid} - 租户 ID</li>
 *     <li>{@code roles} - 角色列表（逗号分隔）</li>
 *     <li>{@code did} - 部门 ID（可选）</li>
 *     <li>{@code ds} - 数据权限范围（可选，默认 3=本人）</li>
 * </ul>
 *
 * @see io.jsonwebtoken.Jwts
 */
@Component
public class JwtUtil {

    /** HMAC-SHA 签名密钥，auth 服务与 gateway 必须一致 */
    @Value("${gov.jwt.secret}")
    private String secret;

    /** Token 有效期（秒） */
    @Value("${gov.jwt.expire}")
    private long expire;

    /** 构造 HMAC-SHA 签名密钥 */
    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 生成 Token（基础版，不含数据权限）
     *
     * @param userId   用户ID
     * @param tenantId 租户ID（政务多租户标识）
     * @param roles    角色，多个用逗号分隔
     */
    public String createToken(String userId, String tenantId, String roles) {
        return Jwts.builder()
                .claim("uid", userId)
                .claim("tid", tenantId)
                .claim("roles", roles)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expire * 1000))
                .signWith(key())
                .compact();
    }

    /**
     * 解析 Token 并验证签名
     *
     * @return JWT Claims 载荷
     * @throws io.jsonwebtoken.JwtException 签名无效或已过期时抛出
     */
    public Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(key())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * 生成 Token（完整版，含部门与数据权限）
     *
     * @param userId   用户ID
     * @param tenantId 租户ID
     * @param roles    角色列表
     * @param deptId   部门ID
     * @param dataScope 数据权限范围（1=全部 2=部门及以下 3=本人）
     */
    public String createToken(String userId, String tenantId, String roles,
                              Long deptId, Integer dataScope) {
        return Jwts.builder()
                .claim("uid", userId)
                .claim("tid", tenantId)
                .claim("roles", roles)
                .claim("did", deptId == null ? "" : String.valueOf(deptId))
                .claim("ds", dataScope == null ? 3 : dataScope)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + expire * 1000))
                .signWith(key())
                .compact();
    }
}