package com.gov.auth.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${gov.jwt.secret}")
    private String secret;

    @Value("${gov.jwt.expire}")
    private long expire;

    private SecretKey key() {
        return Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 生成 Token
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
     * 解析 Token
     */
    public Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(key()) // 使用 verifyWith 替换 setSigningKey
                .build()
                .parseSignedClaims(token) // 使用 parseSignedClaims 替换 parseClaimsJws
                .getPayload(); // 使用 getPayload 替换 getBody
    }

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

