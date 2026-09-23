package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.ApplicationLog;
import com.gov.application.mapper.ApplicationLogMapper;
import com.gov.application.service.ApplicationLogService;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ApplicationLogServiceImpl implements ApplicationLogService {

    @Autowired
    private ApplicationLogMapper logMapper;

    @Override
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

    @Override
    public List<ApplicationLog> listByApplication(Long applicationId) {
        return logMapper.selectList(
                new LambdaQueryWrapper<ApplicationLog>()
                        .eq(ApplicationLog::getApplicationId, applicationId)
                        .orderByAsc(ApplicationLog::getCreateTime));
    }
}