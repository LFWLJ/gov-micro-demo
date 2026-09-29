package com.gov.file.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.common.exception.BizException;
import com.gov.common.redis.RedisService;
import com.gov.file.config.MinioProperties;
import com.gov.file.entity.FileInfo;
import com.gov.file.mapper.FileInfoMapper;
import com.gov.file.service.FileService;
import io.minio.*;
import io.minio.http.Method;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

@Service
public class FileServiceImpl implements FileService {

    private static final Logger log = LoggerFactory.getLogger(FileServiceImpl.class);

    /**
     * 允许上传的扩展名白名单。
     * 刻意排除 html/htm/svg/js/xml 等浏览器可执行类型，避免存储型 XSS。
     */
    private static final Set<String> ALLOWED_EXT = Set.of(
            "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "csv",
            "png", "jpg", "jpeg", "gif", "bmp", "webp",
            "zip", "rar", "7z", "mp4", "mp3", "wav");

    /** 租户标识格式校验：它会被用作对象键前缀，必须排除路径穿越字符 */
    private static final Pattern TENANT_ID_PATTERN = Pattern.compile("^[A-Za-z0-9_-]{1,32}$");

    @Autowired
    private MinioClient minioClient;

    @Autowired
    private MinioProperties props;

    @Autowired
    private RedisService redisService;

    @Autowired
    private FileInfoMapper fileInfoMapper;

    @Override
    public Map<String, Object> upload(MultipartFile file, String tenantId) {
        if (file == null || file.isEmpty()) throw new BizException("文件不能为空");
        if (tenantId == null || !TENANT_ID_PATTERN.matcher(tenantId).matches()) {
            throw new BizException("缺少或非法的租户标识");
        }

        String originalName = file.getOriginalFilename();
        if (originalName == null || !originalName.contains(".")) {
            throw new BizException("文件缺少扩展名，无法识别类型");
        }
        // ★ 扩展名必须落在白名单内，且只保留字母数字（防路径穿越/双扩展名绕过）
        String cleanExt = originalName.substring(originalName.lastIndexOf(".") + 1)
                .toLowerCase().replaceAll("[^a-z0-9]", "");
        if (!ALLOWED_EXT.contains(cleanExt)) {
            throw new BizException("不支持的文件类型: " + cleanExt);
        }
        String ext = "." + cleanExt;

        LocalDate today = LocalDate.now();
        String objectName = String.format("%s/%d/%02d%02d/%s%s",
                tenantId, today.getYear(), today.getMonthValue(), today.getDayOfMonth(),
                UUID.randomUUID().toString().replace("-", ""), ext);

        // MinIO 的 contentType 不允许为 null（否则 putObject 直接抛异常），缺省给安全类型
        String contentType = file.getContentType();
        if (contentType == null || contentType.isEmpty()) {
            contentType = "application/octet-stream";
        }

        try (InputStream is = file.getInputStream()) {
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(props.getBucket())
                            .object(objectName)
                            .stream(is, file.getSize(), -1)
                            .contentType(contentType)
                            .build());
        } catch (Exception e) {
            throw new BizException("文件上传失败: " + e.getMessage());
        }

        String fileId = UUID.randomUUID().toString().replace("-", "");

        FileInfo info = new FileInfo();
        info.setFileId(fileId);
        info.setTenantId(tenantId);
        info.setUserId(com.gov.common.tenant.UserContext.getUserId());
        info.setOriginalName(originalName);
        info.setObjectName(objectName);
        info.setContentType(contentType);
        info.setSize(file.getSize());
        fileInfoMapper.insert(info);

        Map<String, Object> result = new HashMap<>();
        result.put("fileId", fileId);
        result.put("objectName", objectName);
        result.put("originalName", originalName);
        result.put("size", file.getSize());
        result.put("contentType", contentType);
        return result;
    }

    /**
     * 校验 objectName 归属当前租户。
     * t_file 已纳入 MyBatis-Plus 租户拦截器，因此这里的查询会自动带上 tenant_id 条件；
     * 查不到即视为"不存在或不属于本租户"，从而阻断按对象名越权下载/删除。
     */
    private FileInfo requireOwnedFile(String objectName) {
        if (objectName == null || objectName.isEmpty()) {
            throw new BizException("对象名不能为空");
        }
        List<FileInfo> list = fileInfoMapper.selectList(
                new LambdaQueryWrapper<FileInfo>()
                        .eq(FileInfo::getObjectName, objectName));
        if (list.isEmpty()) {
            throw new BizException("文件不存在");
        }
        return list.get(0);
    }

    @Override
    public String getPresignedUrl(String objectName) {
        requireOwnedFile(objectName);
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

    @Override
    public InputStream download(String objectName) {
        requireOwnedFile(objectName);
        try {
            return minioClient.getObject(
                    GetObjectArgs.builder().bucket(props.getBucket()).object(objectName).build());
        } catch (Exception e) {
            throw new BizException("文件不存在: " + objectName);
        }
    }

    @Override
    public void delete(String objectName) {
        // ★ 先确认归属，再动数据与对象存储（否则可凭对象名删掉别家租户的文件）
        FileInfo owned = requireOwnedFile(objectName);

        // 1. 删数据库记录（先删库，避免 MinIO 删了库没删的脏数据）
        int deleted = fileInfoMapper.deleteById(owned.getId());
        log.info("删除文件记录: objectName={}, affected={}", objectName, deleted);

        // 2. 删 MinIO 对象（对象可能已不存在，失败不阻塞）
        try {
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(props.getBucket())
                            .object(objectName)
                            .build());
        } catch (Exception e) {
            log.warn("删除 MinIO 对象失败: {}", objectName, e);
        }
    }
}