package com.gov.common.log.impl;

import com.gov.common.log.OperLog;
import com.gov.common.log.OperLogMapper;
import com.gov.common.log.OperLogService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class OperLogServiceImpl implements OperLogService {

    private static final Logger log = LoggerFactory.getLogger(OperLogServiceImpl.class);

    @Autowired(required = false)
    private OperLogMapper operLogMapper;

    @Override
    @Async("logExecutor")
    public void save(OperLog operLog) {
        if (operLogMapper == null) {
            log.debug("OperLogMapper 未配置，跳过日志入库：{}", operLog.getOperation());
            return;
        }
        try {
            if (operLog.getTenantId() == null || operLog.getTenantId().isEmpty()) {
                operLog.setTenantId("__SYSTEM__");
            }
            operLogMapper.insert(operLog);
        } catch (Exception e) {
            log.error("写入操作日志失败", e);
        }
    }
}