package com.gov.gateway;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import java.net.InetSocketAddress;
import java.net.Socket;

import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * 上下文冒烟测试：验证网关（WebFlux + Nacos 配置 + 响应式 Redis）能否正常装配。
 *
 * <p>需要 Nacos(8848) 等中间件在位；CI runner 上没有服务，故先探测端口，
 * **连不上就跳过**，避免把环境缺失当成代码缺陷。本地 {@code docker compose up -d} 后会自动执行。
 * 探测端口可用 {@code -Dgov.test.infra.port=xxxx} 覆盖。
 */
@SpringBootTest
class GovGatewayApplicationTests {

    private static final int INFRA_PORT = Integer.getInteger("gov.test.infra.port", 8848);

    @BeforeAll
    static void requireInfra() {
        assumeTrue(portOpen(), "127.0.0.1:" + INFRA_PORT + " 不可达（无中间件），跳过上下文冒烟测试");
    }

    private static boolean portOpen() {
        try (Socket socket = new Socket()) {
            socket.connect(new InetSocketAddress("127.0.0.1", INFRA_PORT), 800);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @Test
    void contextLoads() {
    }
}
