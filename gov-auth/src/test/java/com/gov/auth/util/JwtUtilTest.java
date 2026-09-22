package com.gov.auth.util;

import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;

import static org.junit.jupiter.api.Assertions.*;

class JwtUtilTest {

    private JwtUtil jwtUtil;

    @BeforeEach
    void setUp() throws Exception {
        jwtUtil = new JwtUtil();

        // 通过反射设置私有字段
        Field secretField = JwtUtil.class.getDeclaredField("secret");
        secretField.setAccessible(true);
        secretField.set(jwtUtil, "test-secret-key-must-be-long-enough-for-hs256");

        Field expireField = JwtUtil.class.getDeclaredField("expire");
        expireField.setAccessible(true);
        expireField.set(jwtUtil, 7200L);
    }

    @Test
    void testCreateAndParseToken() {
        String token = jwtUtil.createToken("1001", "tenant_a", "ROLE_ADMIN");

        assertNotNull(token, "Token 不应为 null");
        assertFalse(token.isEmpty(), "Token 不应为空");
        // JWT 有三段，用 . 分隔
        assertEquals(3, token.split("\\.").length, "JWT 应有 3 段");
    }

    @Test
    void testParseClaims() {
        String token = jwtUtil.createToken("1001", "tenant_a", "ROLE_ADMIN");
        Claims claims = jwtUtil.parse(token);

        assertEquals("1001", claims.get("uid"));
        assertEquals("tenant_a", claims.get("tid"));
        assertEquals("ROLE_ADMIN", claims.get("roles"));
        assertNotNull(claims.getExpiration(), "过期时间不应为空");
    }

    @Test
    void testParseInvalidToken() {
        assertThrows(Exception.class, () -> jwtUtil.parse("invalid.token.here"),
                "解析非法 Token 应抛异常");
    }

    @Test
    void testTokenExpiration() {
        String token = jwtUtil.createToken("1001", "tenant_a", "ROLE_ADMIN");
        Claims claims = jwtUtil.parse(token);

        long now = System.currentTimeMillis();
        long expire = claims.getExpiration().getTime();
        assertTrue(expire > now, "过期时间应大于当前时间");
        // 7200秒 ≈ 7200000ms，允许一定误差
        long diff = expire - now;
        assertTrue(diff > 7100_000 && diff <= 7200_000,
                "有效期应约为 7200 秒，实际：" + diff + "ms");
    }
}