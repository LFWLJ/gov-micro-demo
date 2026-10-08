package com.gov.gateway.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * 全链路追踪过滤器
 * <p>
 * 作为网关最前置的过滤器（order = -200），为每一条请求分配唯一的 traceId：
 * <ul>
 *     <li>若客户端请求头已携带 {@code X-Trace-Id}，则沿用（跨系统调用透传场景）</li>
 *     <li>否则生成 32 位无横线 UUID 作为新的 traceId</li>
 * </ul>
 * traceId 会被同时写入下游请求头和响应头，方便在日志系统中串联整条调用链。
 * </p>
 *
 * @see TenantAuthGlobalFilter
 */
@Component
public class TraceGlobalFilter implements GlobalFilter, Ordered {

    private static final Logger log = LoggerFactory.getLogger(TraceGlobalFilter.class);

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String traceId = exchange.getRequest().getHeaders().getFirst("X-Trace-Id");
        if (traceId == null || traceId.isEmpty()) {
            traceId = UUID.randomUUID().toString().replace("-", "");
            log.debug("网关生成 traceId={}", traceId);
        }

        ServerHttpRequest request = exchange.getRequest().mutate()
                .header("X-Trace-Id", traceId)
                .build();

        exchange.getResponse().getHeaders().add("X-Trace-Id", traceId);

        return chain.filter(exchange.mutate().request(request).build());
    }

    /**
     * 返回 -200，确保在 {@link TenantAuthGlobalFilter}（-100）之前执行，
     * 这样鉴权日志也能带上 traceId。
     */
    @Override
    public int getOrder() {
        return -200;
    }
}