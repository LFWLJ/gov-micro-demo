package com.gov.file.service;

import com.gov.common.exception.BizException;
import com.gov.common.redis.RedisService;
import com.gov.file.config.MinioProperties;
import com.gov.file.entity.FileInfo;
import com.gov.file.mapper.FileInfoMapper;
import io.minio.*;
import io.minio.http.Method;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
public class FileService {

    @Autowired
    private MinioClient minioClient;

    @Autowired
    private MinioProperties props;

    @Autowired
    private RedisService redisService;

    @Autowired
    private FileInfoMapper fileInfoMapper;

    public Map<String, Object> upload(MultipartFile file, String tenantId) {
        if (file == null || file.isEmpty()) throw new BizException("文件不能为空");
        if (tenantId == null || tenantId.isEmpty()) throw new BizException("缺少租户标识");

        String originalName = file.getOriginalFilename();
        String ext = "";
        if (originalName != null && originalName.contains(".")) {
            ext = originalName.substring(originalName.lastIndexOf("."));
        }

        LocalDate today = LocalDate.now();
        String objectName = String.format("%s/%d/%02d%02d/%s%s",
                tenantId, today.getYear(), today.getMonthValue(), today.getDayOfMonth(),
                UUID.randomUUID().toString().replace("-", ""), ext);

        try (InputStream is = file.getInputStream()) {
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(props.getBucket())
                            .object(objectName)
                            .stream(is, file.getSize(), -1)
                            .contentType(file.getContentType())
                            .build());
        } catch (Exception e) {
            throw new BizException("文件上传失败: " + e.getMessage());
        }

        String fileId = UUID.randomUUID().toString().replace("-", "");

        // ★ 写入数据库
        FileInfo info = new FileInfo();
        info.setFileId(fileId);
        info.setTenantId(tenantId);
        info.setUserId(com.gov.common.tenant.UserContext.getUserId());
        info.setOriginalName(originalName);
        info.setObjectName(objectName);
        info.setContentType(file.getContentType());
        info.setSize(file.getSize());
        fileInfoMapper.insert(info);

        Map<String, Object> result = new HashMap<>();
        result.put("fileId", fileId);
        result.put("objectName", objectName);
        result.put("originalName", originalName);
        result.put("size", file.getSize());
        result.put("contentType", file.getContentType());
        return result;
    }

    public String getPresignedUrl(String objectName) {
        try {
            return minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(props.getBucket())
                            .object(objectName)
                            .expiry(props.getPresignedExpiry(), TimeUnit.SECONDS)
                            .build());
        } catch (Exception e) {
            throw new BizException("生成下载链接失败: " + e.getMessage());
        }
    }

    public InputStream download(String objectName) {
        try {
            return minioClient.getObject(
                    GetObjectArgs.builder().bucket(props.getBucket()).object(objectName).build());
        } catch (Exception e) {
            throw new BizException("文件不存在: " + objectName);
        }
    }

    public void delete(String objectName) {
        try {
            minioClient.removeObject(
                    RemoveObjectArgs.builder().bucket(props.getBucket()).object(objectName).build());
        } catch (Exception e) {
            throw new BizException("文件删除失败: " + e.getMessage());
        }
    }
}