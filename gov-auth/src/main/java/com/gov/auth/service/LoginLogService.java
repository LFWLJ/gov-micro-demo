package com.gov.auth.service;

import jakarta.servlet.http.HttpServletRequest;

public interface LoginLogService {

    void record(String username, String tenantId, String msg,
                boolean success, HttpServletRequest request);
}