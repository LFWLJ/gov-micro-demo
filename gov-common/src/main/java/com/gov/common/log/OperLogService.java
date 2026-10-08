package com.gov.common.log;

/**
 * 操作日志服务接口
 * <p>
 * 提供操作日志的持久化能力，由 {@link OperLogServiceImpl} 默认实现，
 * 被 {@link OperLogAspect} 切面自动调用。
 * </p>
 *
 * @see OperLogServiceImpl
 * @see OperLogAspect
 */
public interface OperLogService {

    /**
     * 保存一条操作日志
     *
     * @param operLog 日志实体（已由切面填充完整）
     */
    void save(OperLog operLog);
}