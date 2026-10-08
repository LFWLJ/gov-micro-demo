package com.gov.common.mybatis;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.TenantLineInnerInterceptor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis-Plus 全局插件配置
 * <p>
 * 注册两个内层拦截器，注意 <b>顺序不可颠倒</b>：
 * <ol>
 *   <li><b>多租户插件</b> — 先拦截，在 SQL 上追加 {@code WHERE tenant_id = ?}</li>
 *   <li><b>分页插件</b> — 后拦截，在已经带好租户条件的 SQL 上包一层 {@code LIMIT}，
 *       保证分页是在"租户隔离后的数据集合"上进行</li>
 * </ol>
 * 若顺序颠倒，分页插件会先改写 SQL，多租户插件再拼接条件，
 * 可能导致 MySQL 的 LIMIT + WHERE 语法兼容问题。
 * </p>
 *
 * @see TenantLineHandlerImpl
 */
@Configuration
public class MybatisPlusConfig {

    /**
     * 构造 MyBatis-Plus 拦截器链
     *
     * @return 已注册多租户 + 分页的拦截器实例
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();

        // 多租户插件（必须在分页插件之前）
        TenantLineInnerInterceptor tenantInterceptor =
                new TenantLineInnerInterceptor(new TenantLineHandlerImpl());
        interceptor.addInnerInterceptor(tenantInterceptor);

        // 分页插件
        PaginationInnerInterceptor pagination =
                new PaginationInnerInterceptor(DbType.MYSQL);
        pagination.setMaxLimit(500L);
        interceptor.addInnerInterceptor(pagination);

        return interceptor;
    }
}