package com.gov.common.log.impl;

import com.gov.common.log.OperLog;
import com.gov.common.log.OperLogMapper;
import com.gov.common.log.OperLogService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

/**
 * 操作日志服务默认实现
 * <p>
 * 通过 MyBatis-Plus 的 {@code BaseMapper.insert} 将日志写入 {@code sys_oper_log} 表。
 * 由于 {@link OperLogAspect} 已对切面内部异常做了隔离，这里的 save 是同步执行的，
 * 如需异步写入可在方法上加 {@code @Async("logExecutor")}（线程池已在
 * {@link com.gov.common.log.LogAsyncConfig} 中配置）。
 * </p>
 */
@Service
public class OperLogServiceImpl implements OperLogService {

    @Resource
    private OperLogMapper operLogMapper;

    @Override
    public void save(OperLog operLog) {
        operLogMapper.insert(operLog);
    }
}