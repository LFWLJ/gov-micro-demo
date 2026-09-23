package com.gov.application.service;

import com.gov.application.entity.SysConfig;

import java.util.List;

public interface ConfigService {

    List<SysConfig> list(String keyword);

    String getValue(String key);

    Long create(SysConfig config);

    void update(SysConfig config);

    void delete(Long id);
}