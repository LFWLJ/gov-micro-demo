package com.gov.common.log;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

/**
 * 操作日志异步线程池配置
 * <p>
 * 启用 Spring 的异步能力，并注册一个名为 {@code logExecutor} 的线程池 Bean。
 * 业务方在需要异步写入日志时，可在 Service 方法上声明
 * {@code @Async("logExecutor")}，避免日志 IO 阻塞主请求链路。
 * </p>
 *
 * <p>线程池参数说明：</p>
 * <ul>
 *   <li>核心线程数 2、最大线程数 4 — 日志写入属于低优先级 IO，不宜占用过多资源</li>
 *   <li>队列容量 500 — 足够支撑短时日志突发</li>
 *   <li>拒绝策略 {@code DiscardOldestPolicy} — 队列满时丢弃最旧日志，保证业务主线程</li>
 *   <li>线程名前缀 {@code oplog-} — 便于排查线程问题</li>
 * </ul>
 */
@Configuration
@EnableAsync
public class LogAsyncConfig {

    /**
     * 日志专用异步线程池
     *
     * @return 线程池执行器，Bean 名称为 {@code logExecutor}
     */
    @Bean("logExecutor")
    public Executor logExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(4);
        executor.setQueueCapacity(500);
        executor.setThreadNamePrefix("oplog-");
        // 队列满时丢弃最旧任务，优先保证主业务线程
        executor.setRejectedExecutionHandler(
                new java.util.concurrent.ThreadPoolExecutor.DiscardOldestPolicy());
        executor.initialize();
        return executor;
    }
}