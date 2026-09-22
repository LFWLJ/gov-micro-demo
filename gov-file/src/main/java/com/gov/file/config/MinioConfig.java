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

@Configuration
@EnableConfigurationProperties(MinioProperties.class)
public class MinioConfig {

    private static final Logger log = LoggerFactory.getLogger(MinioConfig.class);

    @Autowired
    private MinioProperties props;

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