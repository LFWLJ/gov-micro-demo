package com.gov.common.log;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class OperLogService {

    private static final Logger log = LoggerFactory.getLogger(OperLogService.class);

    @Autowired(required = false)
    private OperLogMapper operLogMapper;

    @Async("logExecutor")
    public void save(OperLog operLog) {
        if (operLogMapper == null) {
            log.debug("OperLogMapper 未配置，跳过日志入库：{}", operLog.getOperation());
            return;
        }
        try {
            // 兜底：租户为空时填 __SYSTEM__
            if (operLog.getTenantId() == null || operLog.getTenantId().isEmpty()) {
                operLog.setTenantId("__SYSTEM__");
            }
            operLogMapper.insert(operLog);
        } catch (Exception e) {
            log.error("写入操作日志失败", e);
        }
    }
}