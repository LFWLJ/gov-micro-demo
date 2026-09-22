package com.gov.api.feign;

import com.gov.api.dto.FileUploadDTO;
import com.gov.common.result.R;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@FeignClient(
        name = "gov-file",
        path = "/api/file",
        contextId = "fileFeignClient",
        fallbackFactory = FileFeignClientFallbackFactory.class
)
public interface FileFeignClient {

    /** 获取预签名下载 URL */
    @GetMapping("/url")
    R<Map<String, Object>> getUrl(@RequestParam("objectName") String objectName);

    /** 删除文件 */
    @DeleteMapping
    R<Void> delete(@RequestParam("objectName") String objectName);

    @GetMapping("/stats")
    R<Map<String, Object>> getStats();
}