package com.gov.api.feign;

import com.gov.common.result.R;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.openfeign.FallbackFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * 文件服务 Feign 降级工厂
 * <p>
 * 当 gov-file 服务不可达（网络异常、超时、5xx）时，由该工厂产生降级实现。
 * 所有方法统一返回 {@code R.fail(503, "...")}，避免调用方 NPE，
 * 并通过 {@code log.error} 记录原始异常方便排查。
 * </p>
 */
@Component
public class FileFeignClientFallbackFactory implements FallbackFactory<FileFeignClient> {

    private static final Logger log = LoggerFactory.getLogger(FileFeignClientFallbackFactory.class);

    @Override
    public FileFeignClient create(Throwable cause) {
        log.error("调用 gov-file 失败", cause);
        return new FileFeignClient() {
            @Override
            public R<Map<String, Object>> getUrl(String objectName) {
                return R.fail(503, "文件服务暂时不可用，请稍后重试");
            }

            @Override
            public R<Void> delete(String objectName) {
                return R.fail(503, "文件服务暂时不可用，请稍后重试");
            }

            @Override
            public R<Map<String, Object>> getStats() {
                return R.fail(503, "文件服务暂时不可用，请稍后重试");
            }
        };
    }
}