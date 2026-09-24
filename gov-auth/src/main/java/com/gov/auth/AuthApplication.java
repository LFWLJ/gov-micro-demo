package com.gov.auth;

import org.apache.ibatis.annotations.Mapper;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

@EnableFeignClients(basePackages = "com.gov.api.feign")
@SpringBootApplication(scanBasePackages = {"com.gov.auth", "com.gov.common"})
@EnableDiscoveryClient
@MapperScan(basePackages = {"com.gov.auth.mapper", "com.gov.common.log"},
        annotationClass = Mapper.class)
public class AuthApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthApplication.class, args);
    }
}