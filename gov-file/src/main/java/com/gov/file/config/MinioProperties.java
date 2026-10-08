package com.gov.file.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;


/**
 * MinIO 配置属性
 * <p>
 * 对应 application.yml 中 {@code minio.*} 节点。
 * </p>
 */
@ConfigurationProperties(prefix = "minio")
public class MinioProperties {
    /** MinIO 服务地址，如 {@code http://127.0.0.1:9000} */
    private String endpoint;
    /** 访问密钥 */
    private String accessKey;
    /** 密钥 */
    private String secretKey;
    /** 使用的 bucket 名称 */
    private String bucket;
    /** 预签名 URL 过期时间（秒），默认 3600（1 小时） */
    private int presignedExpiry = 3600;

    public String getEndpoint() { return endpoint; }
    public void setEndpoint(String endpoint) { this.endpoint = endpoint; }

    public String getAccessKey() { return accessKey; }
    public void setAccessKey(String accessKey) { this.accessKey = accessKey; }

    public String getSecretKey() { return secretKey; }
    public void setSecretKey(String secretKey) { this.secretKey = secretKey; }

    public String getBucket() { return bucket; }
    public void setBucket(String bucket) { this.bucket = bucket; }

    public int getPresignedExpiry() { return presignedExpiry; }
    public void setPresignedExpiry(int presignedExpiry) { this.presignedExpiry = presignedExpiry; }
}