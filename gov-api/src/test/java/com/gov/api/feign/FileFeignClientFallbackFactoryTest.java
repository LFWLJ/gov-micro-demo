package com.gov.api.feign;

import com.gov.common.result.R;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Feign 降级工厂回归测试。
 *
 * <p>重点：**任何降级方法都不得返回 null**。
 * 原实现 {@code getStats()} 返回 null，调用方（ApplicationController）会直接 NPE，
 * 把"文件服务不可用"变成"业务接口 500"，这里把它钉住。
 *
 * <p>本模块（gov-api）是纯契约库，没有 {@code @SpringBootApplication}，
 * 因此不能使用 {@code @SpringBootTest}（会报 Unable to find a @SpringBootConfiguration）。
 */
class FileFeignClientFallbackFactoryTest {

    @Test
    void fallbackNeverReturnsNull() {
        FileFeignClient client = new FileFeignClientFallbackFactory()
                .create(new RuntimeException("模拟 gov-file 不可用"));

        assertNotNull(client, "降级实例不应为 null");

        R<Map<String, Object>> url = client.getUrl("any/object.txt");
        assertNotNull(url, "getUrl 降级不得返回 null");
        assertEquals(503, url.getCode(), "降级应返回 503");

        R<Void> deleted = client.delete("any/object.txt");
        assertNotNull(deleted, "delete 降级不得返回 null");
        assertEquals(503, deleted.getCode(), "降级应返回 503");

        R<Map<String, Object>> stats = client.getStats();
        assertNotNull(stats, "getStats 降级不得返回 null（原实现返回 null 会导致调用方 NPE）");
        assertEquals(503, stats.getCode(), "降级应返回 503");
    }
}