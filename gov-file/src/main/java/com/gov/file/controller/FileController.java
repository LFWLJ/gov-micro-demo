package com.gov.file.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.file.entity.FileInfo;
import com.gov.file.mapper.FileInfoMapper;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import com.gov.file.mapper.FileInfoMapper;
import com.gov.file.service.FileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "文件服务", description = "上传、下载、删除")
@RestController
@RequestMapping("/api/file")
public class FileController {

    @Autowired
    private FileService fileService;
    @Autowired
    private FileInfoMapper fileInfoMapper;

    @Operation(summary = "上传文件")
    @PostMapping("/upload")
    @OpLog(module = "文件服务", operation = "上传文件", saveParams = false)
    public R<Map<String, Object>> upload(
            @RequestParam("file") MultipartFile file,
            @RequestHeader(value = "X-User-Id", required = false) String userId,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        return R.ok("上传成功", fileService.upload(file, tenantId));
    }

    @Operation(summary = "获取预签名下载链接")
    @GetMapping("/url")
    public R<Map<String, Object>> getUrl(@RequestParam String objectName) {
        return R.ok(Map.of("url", fileService.getPresignedUrl(objectName)));
    }

    @Operation(summary = "直接下载文件")
    @GetMapping("/download")
    public void download(@RequestParam String objectName,
                         @RequestParam(required = false) String fileName,
                         HttpServletResponse response) throws Exception {
        try (InputStream is = fileService.download(objectName)) {
            String name = fileName != null ? fileName : "download";
            response.setHeader("Content-Disposition",
                    "attachment; filename=" + URLEncoder.encode(name, StandardCharsets.UTF_8));
            response.setContentType("application/octet-stream");
            StreamUtils.copy(is, response.getOutputStream());
        }
    }

    @Operation(summary = "删除文件")
    @DeleteMapping
    @OpLog(module = "文件服务", operation = "删除文件")
    public R<Void> delete(@RequestParam String objectName) {
        fileService.delete(objectName);
        return R.ok("删除成功", null);
    }

    @Operation(summary = "查询当前用户上传的文件数")
    @GetMapping("/my-count")
    public R<Map<String, Object>> myCount(
            @RequestHeader(value = "X-User-Id", required = false) String userId,
            @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        Map<String, Object> data = new HashMap<>();
        data.put("userId", userId);
        data.put("tenantId", tenantId);
        data.put("msg", "feign 调用时用户上下文透传成功");
        return R.ok(data);
    }

    @Operation(summary = "分页查询文件")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "keyword", required = false) String keyword) {

        LambdaQueryWrapper<FileInfo> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(FileInfo::getOriginalName, keyword);
        }
        wrapper.orderByDesc(FileInfo::getId);

        Page<FileInfo> p = new Page<>(page, size);
        Page<FileInfo> result = fileInfoMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return R.ok(data);
    }

    @Operation(summary = "文件统计")
    @GetMapping("/stats")
    public R<Map<String, Object>> stats() {
        Long total = fileInfoMapper.selectCount(null);
        List<FileInfo> files = fileInfoMapper.selectList(null);
        long totalSize = files.stream()
                .mapToLong(f -> f.getSize() == null ? 0 : f.getSize())
                .sum();

        Map<String, Object> data = new HashMap<>();
        data.put("total", total);
        data.put("totalSize", totalSize);
        return R.ok(data);
    }
}