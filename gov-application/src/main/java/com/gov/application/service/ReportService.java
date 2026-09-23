package com.gov.application.service;

import com.gov.application.entity.Application;

import java.util.List;
import java.util.Map;

public interface ReportService {

    List<Map<String, Object>> statByDept(String startTime, String endTime);

    List<Map<String, Object>> statByDate(String startTime, String endTime);

    Map<String, Object> summary(String startTime, String endTime);

    List<Application> detailList(String startTime, String endTime, Long deptId);
}