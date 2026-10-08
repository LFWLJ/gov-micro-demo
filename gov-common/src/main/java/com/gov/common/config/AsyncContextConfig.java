package com.gov.common.config;

import com.gov.common.tenant.TenantContext;
import com.gov.common.tenant.UserContext;
import org.slf4j.MDC;
import org.springframework.aop.interceptor.AsyncUncaughtExceptionHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.TaskDecorator;
import org.springframework.scheduling.annotation.AsyncConfigurer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.Map;
import java.util.concurrent.Executor;

/**
 * 异步线程池配置（默认 {@code @Async} 执行器）
 * <p>
 * 设计要点：
 * <ol>
 *   <li><b>Bean 命名为 {@code govTaskExecutor}</b> — 避免和 Flowable 自带的 {@code taskExecutor} Bean 冲突</li>
 *   <li><b>实现 {@link AsyncConfigurer}</b> — 使所有不带参数的 {@code @Async} 自动使用本线程池，
 *       业务代码无需显式指定 Bean 名称</li>
 *   <li><b>ContextAwareDecorator 线程上下文传递</b> — 通过 {@link TaskDecorator} 将主线程的
 *       租户、用户、MDC traceId 拷贝到异步线程中执行，保证异步任务也能正确做租户隔离、
 *       操作日志和链路追踪</li>
 * </ol>
 *
 * @see AsyncConfigurer
 * @see ContextAwareDecorator
 */
@Configuration
@EnableAsync
public class AsyncContextConfig implements AsyncConfigurer {

    /**
     * 主异步线程池
     *
     * @return 线程池 Bean，名称 {@code govTaskExecutor}，也是 {@code @Async} 默认执行器
     */
    @Bean("govTaskExecutor")
    public Executor govTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(8);
        executor.setQueueCapacity(200);
        executor.setThreadNamePrefix("async-");
        // 关键：让每个异步任务继承主线程的 ThreadLocal 上下文
        executor.setTaskDecorator(new ContextAwareDecorator());
        executor.initialize();
        return executor;
    }

    /** @Async 不带参数时，默认使用 govTaskExecutor */
    @Override
    public Executor getAsyncExecutor() {
        return govTaskExecutor();
    }

    /** 异步方法未捕获异常处理：使用 Spring 默认实现（仅打印 warn 日志） */
    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return AsyncConfigurer.super.getAsyncUncaughtExceptionHandler();
    }

    /**
     * 线程上下文传递装饰器
     * <p>
     * 在 Runnable 提交到线程池之前，先将主线程的以下信息做快照：
     * <ul>
     *   <li>{@link TenantContext} — 租户标识（影响多租户 SQL 拼接）</li>
     *   <li>{@link UserContext} — 用户 ID 和租户 ID（影响操作日志和权限）</li>
     *   <li>{@link MDC} — traceId（影响链路追踪日志）</li>
     * </ul>
     * 异步线程执行时恢复这些值，finally 块再清理并还原现场，防止线程池复用时串上下文。
     * </p>
     */
    public static class ContextAwareDecorator implements TaskDecorator {
        @Override
        public Runnable decorate(Runnable runnable) {
            // 1. 在主线程做快照
            String tenantId = TenantContext.get();
            String userId = UserContext.getUserId();
            String userTenant = UserContext.getTenantId();
            Map<String, String> mdcCopy = MDC.getCopyOfContextMap();
            return () -> {
                // 2. 在异步线程恢复快照
                String oldTenant = TenantContext.get();
                String oldUserTenant = UserContext.getTenantId();
                String oldUserId = UserContext.getUserId();
                Map<String, String> oldMdc = MDC.getCopyOfContextMap();
                try {
                    if (tenantId != null) TenantContext.set(tenantId);
                    if (userId != null) UserContext.setUserId(userId);
                    if (userTenant != null) UserContext.setTenantId(userTenant);
                    if (mdcCopy != null) MDC.setContextMap(mdcCopy);
                    runnable.run();
                } finally {
                    // 3. 执行完毕清理，防止线程池复用时脏数据残留
                    if (oldTenant != null) TenantContext.set(oldTenant); else TenantContext.clear();
                    if (oldUserId != null) UserContext.setUserId(oldUserId); else UserContext.clear();
                    if (oldUserTenant != null) UserContext.setTenantId(oldUserTenant);
                    if (oldMdc != null) MDC.setContextMap(oldMdc); else MDC.clear();
                }
            };
        }
    }
}