package com.gov.common.web;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.MDC;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.UUID;

/**
 * 请求链路追踪 Filter
 * <p>
 * 为每个 HTTP 请求生成或复用一个 traceId（放在 {@link MDC} 中），
 * 让该请求产生的所有日志自动带上同一个 traceId，实现全链路追踪。
 * 同时将 traceId 写入响应头 {@code X-Trace-Id}，前端可透传回传给后端。
 * </p>
 *
 * <p>traceId 来源优先级：</p>
 * <ol>
 *   <li>请求头 {@code X-Trace-Id} — 由上游网关 / 调用方透传</li>
 *   <li>自动生成 — 当前端首次请求或上游没传时，生成一个无横线的 UUID</li>
 * </ol>
 *
 * <p>必须在请求结束时调用 {@code MDC.remove}，否则 Tomcat 线程池复用时会串 traceId。</p>
 */
@Component
@Order(0)
public class TraceServletFilter implements Filter {

    /** MDC 中 traceId 的 key */
    private static final String TRACE_ID_KEY = "traceId";
    /** 上游透传 / 响应头的 traceId header 名称 */
    private static final String HEADER_NAME = "X-Trace-Id";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // 优先取上游透传的 traceId，没有就自动生成
        String traceId = req.getHeader(HEADER_NAME);
        if (traceId == null || traceId.isEmpty()) {
            traceId = UUID.randomUUID().toString().replace("-", "");
        }

        MDC.put(TRACE_ID_KEY, traceId);
        // 回写到响应头，前端可据此追踪本次请求
        res.setHeader(HEADER_NAME, traceId);
        try {
            chain.doFilter(request, response);
        } finally {
            // 请求结束必须清理 MDC，防止线程池复用时串 traceId
            MDC.remove(TRACE_ID_KEY);
        }
    }
}