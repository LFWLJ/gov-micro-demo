package com.gov.common.log.impl;

import com.gov.common.log.OperLog;
import com.gov.common.log.OperLogMapper;
import com.gov.common.log.OperLogService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

@Service
public class OperLogServiceImpl implements OperLogService {

    @Resource
    private OperLogMapper operLogMapper;

    @Override
    public void save(OperLog operLog) {
        operLogMapper.insert(operLog);
    }
}