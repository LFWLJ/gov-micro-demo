package com.gov.file.config;

import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MinIO 对象存储配置
 * <p>
 * 初始化 MinIO 客户端 Bean，并在启动时自动检查/创建 bucket。
 * bucket 的 endpoint、accessKey、secretKey、名称均通过 {@link MinioProperties} 配置注入。
 * </p>
 *
 * @see MinioProperties
 */
@Configuration
@EnableConfigurationProperties(MinioProperties.class)
public class MinioConfig {

    private static final Logger log = LoggerFactory.getLogger(MinioConfig.class);

    @Autowired
    private MinioProperties props;

    /**
     * 创建 MinIO 客户端
     * <p>
     * 启动时自动检查目标 bucket 是否存在，不存在则创建。
     * bucket 初始化失败只记日志不阻断启动（可能是首次部署时 MinIO 还未就绪）。
     * </p>
     */
    @Bean
    public MinioClient minioClient() {
        MinioClient client = MinioClient.builder()
                .endpoint(props.getEndpoint())
                .credentials(props.getAccessKey(), props.getSecretKey())
                .build();

        try {
            boolean exists = client.bucketExists(
                    BucketExistsArgs.builder().bucket(props.getBucket()).build());
            if (!exists) {
                client.makeBucket(
                        MakeBucketArgs.builder().bucket(props.getBucket()).build());
                log.info("MinIO bucket 已创建: {}", props.getBucket());
            } else {
                log.info("MinIO bucket 已存在: {}", props.getBucket());
            }
        } catch (Exception e) {
            log.error("MinIO bucket 初始化失败", e);
        }
        return client;
    }
}