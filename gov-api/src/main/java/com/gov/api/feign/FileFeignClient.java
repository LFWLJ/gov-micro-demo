package com.gov.api.feign;

import com.gov.api.dto.FileUploadDTO;
import com.gov.common.result.R;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

/**
 * 文件服务 Feign 客户端
 * <p>
 * 供其他微服务调用 file 服务的文件管理接口，
 * 配置了 {@link FileFeignClientFallbackFactory} 作为降级处理。
 * </p>
 */
@FeignClient(
        name = "gov-file",
        path = "/api/file",
        contextId = "fileFeignClient",
        fallbackFactory = FileFeignClientFallbackFactory.class
)
public interface FileFeignClient {

    /**
     * 获取预签名下载 URL
     * <p>
     * 前端拿到 URL 后可直接从 MinIO 下载文件，不经过后端中转。
     * </p>
     *
     * @param objectName MinIO 对象名（含租户前缀路径）
     * @return 包含 url、expires 等信息的 Map
     */
    @GetMapping("/url")
    R<Map<String, Object>> getUrl(@RequestParam("objectName") String objectName);

    /**
     * 删除文件（同时删除 MinIO 对象和数据库记录）
     *
     * @param objectName MinIO 对象名
     */
    @DeleteMapping
    R<Void> delete(@RequestParam("objectName") String objectName);

    /**
     * 获取文件存储统计信息（总大小、文件数等）
     */
    @GetMapping("/stats")
    R<Map<String, Object>> getStats();
}