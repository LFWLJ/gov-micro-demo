package com.gov.application.service;

import com.gov.application.entity.ApplicationLog;

import java.util.List;

public interface ApplicationLogService {

    void log(Long applicationId, String action, String actionName,
             String operator, String remark);

    List<ApplicationLog> listByApplication(Long applicationId);
}