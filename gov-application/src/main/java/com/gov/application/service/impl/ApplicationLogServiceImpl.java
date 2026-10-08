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

/**
 * 办件操作日志实现
 * <p>
 * 记录办件生命周期内的每一次状态变更（提交 / 审批 / 通过 / 驳回等），
 * 供前端展示办件流转时间线。日志写入时自动从 {@link TenantContext} 取租户 ID，
 * 保证多租户隔离。
 * </p>
 */
@Service
public class ApplicationLogServiceImpl implements ApplicationLogService {

    @Autowired
    private ApplicationLogMapper logMapper;

    /** 写入一条办件操作日志 */
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

    /** 查询指定办件的所有操作日志（按时间升序，形成时间线） */
    @Override
    public List<ApplicationLog> listByApplication(Long applicationId) {
        return logMapper.selectList(
                new LambdaQueryWrapper<ApplicationLog>()
                        .eq(ApplicationLog::getApplicationId, applicationId)
                        .orderByAsc(ApplicationLog::getCreateTime));
    }
}