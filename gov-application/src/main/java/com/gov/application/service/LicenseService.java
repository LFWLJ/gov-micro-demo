package com.gov.application.service;

import com.gov.application.entity.License;

import java.util.List;
import java.util.Map;

public interface LicenseService {

    Map<String, Object> page(int page, int size, String keyword, String status);

    List<com.gov.application.entity.LicenseTemplate> templates();

    Map<String, Object> issue(License license);

    Map<String, Object> verify(String verifyCode);

    void revoke(Long id);

    /** 按需渲染证照 PDF（下载时生成，避免把大对象常驻库/事务） */
    byte[] renderPdf(Long id);
}