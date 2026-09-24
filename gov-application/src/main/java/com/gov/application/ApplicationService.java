package com.gov.application;

import org.apache.ibatis.annotations.Mapper;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication(scanBasePackages = {"com.gov.application", "com.gov.common", "com.gov.api"})
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.gov.api.feign")
@MapperScan(basePackages = {"com.gov.application.mapper", "com.gov.common.log"},
        annotationClass = Mapper.class)
public class ApplicationService {

    public static void main(String[] args) {
        SpringApplication.run(ApplicationService.class, args);
    }
}