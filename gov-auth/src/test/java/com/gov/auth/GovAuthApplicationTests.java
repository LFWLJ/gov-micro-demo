package com.gov.auth;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import java.net.InetSocketAddress;
import java.net.Socket;

import static org.junit.jupiter.api.Assumptions.assumeTrue;

/**
 * 上下文冒烟测试：验证 Spring 容器能否正常装配。
 *
 * <p>它需要 Nacos(8848) 等中间件在位。CI runner 上没有这些服务，
 * 因此这里先探测端口，**连不上就跳过**——把"环境缺失"和"代码有问题"区分开，
 * 而不是让缺少中间件变成构建失败。
 *
 * <p>本地执行 {@code docker compose up -d} 后会自动真正执行。
 * 探测端口可用 {@code -Dgov.test.infra.port=xxxx} 覆盖。
 */
@SpringBootTest
class GovAuthApplicationTests {

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
