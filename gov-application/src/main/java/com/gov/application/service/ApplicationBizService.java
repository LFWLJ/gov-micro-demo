package com.gov.application.service;

import com.gov.application.entity.Application;

import java.util.List;

public interface ApplicationBizService {

    List<Application> listCurrentTenant();

    Long create(String title, String applicant,
                String deptLeader, String director, String hr, Integer days);

    void reject(Long id, String remark);

    void withdraw(Long id, String remark);

    Application getById(Long id);

    int delete(Long id);
}