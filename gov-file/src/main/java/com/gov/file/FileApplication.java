package com.gov.file;

import org.apache.ibatis.annotations.Mapper;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = {"com.gov.file", "com.gov.common"})
@EnableDiscoveryClient
@MapperScan(basePackages = {"com.gov.file.mapper", "com.gov.common.log"},
        annotationClass = Mapper.class)
public class FileApplication {

    public static void main(String[] args) {
        SpringApplication.run(FileApplication.class, args);
    }
}