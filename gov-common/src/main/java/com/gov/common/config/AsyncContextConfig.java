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
 * 异步线程池配置
 * 1. bean 命名为 govTaskExecutor，避免和 Flowable 的 taskExecutor 冲突
 * 2. 实现 AsyncConfigurer，让 @Async（无参）默认使用本线程池
 *    —— 这样其他地方不用改注解
 */
@Configuration
@EnableAsync
public class AsyncContextConfig implements AsyncConfigurer {

    @Bean("govTaskExecutor")
    public Executor govTaskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(4);
        executor.setMaxPoolSize(8);
        executor.setQueueCapacity(200);
        executor.setThreadNamePrefix("async-");
        executor.setTaskDecorator(new ContextAwareDecorator());
        executor.initialize();
        return executor;
    }

    /** @Async 不带参数时，用这个执行器 */
    @Override
    public Executor getAsyncExecutor() {
        return govTaskExecutor();
    }

    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return AsyncConfigurer.super.getAsyncUncaughtExceptionHandler();
    }

    public static class ContextAwareDecorator implements TaskDecorator {
        @Override
        public Runnable decorate(Runnable runnable) {
            String tenantId = TenantContext.get();
            String userId = UserContext.getUserId();
            String userTenant = UserContext.getTenantId();
            Map<String, String> mdcCopy = MDC.getCopyOfContextMap();
            return () -> {
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
                    if (oldTenant != null) TenantContext.set(oldTenant); else TenantContext.clear();
                    if (oldUserId != null) UserContext.setUserId(oldUserId); else UserContext.clear();
                    if (oldUserTenant != null) UserContext.setTenantId(oldUserTenant);
                    if (oldMdc != null) MDC.setContextMap(oldMdc); else MDC.clear();
                }
            };
        }
    }
}