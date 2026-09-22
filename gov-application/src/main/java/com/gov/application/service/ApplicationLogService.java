package com.gov.application.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.ApplicationLog;
import com.gov.application.mapper.ApplicationLogMapper;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ApplicationLogService {

    @Autowired
    private ApplicationLogMapper logMapper;

    /**
     * 记录流转日志
     */
    public void log(Long applicationId, String action, String actionName,
                    String operator, String remark) {
        ApplicationLog log = new ApplicationLog();
        log.setTenantId(TenantContext.get());
        log.setApplicationId(applicationId);
        log.setAction(action);
        log.setActionName(actionName);
        log.setOperator(operator);
        log.setRemark(remark);
        log.setCreateTime(LocalDateTime.now());
        logMapper.insert(log);
    }

    /**
     * 按事项ID查流转日志
     */
    public List<ApplicationLog> listByApplication(Long applicationId) {
        return logMapper.selectList(
                new LambdaQueryWrapper<ApplicationLog>()
                        .eq(ApplicationLog::getApplicationId, applicationId)
                        .orderByAsc(ApplicationLog::getCreateTime));
    }
}