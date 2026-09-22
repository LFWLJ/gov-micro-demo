package com.gov.file;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = {"com.gov.file", "com.gov.common"})
@EnableDiscoveryClient
@MapperScan({"com.gov.common.log", "com.gov.file.mapper"})
public class FileApplication {
    public static void main(String[] args) {
        SpringApplication.run(FileApplication.class, args);
        System.out.println(">>> gov-file 启动成功，端口 8083");
    }
}