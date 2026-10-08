package com.gov.application.mq;

import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

/**
 * RocketMQ 通知生产者
 * <p>
 * 负责将 {@link NotifyMessage} 投递到 {@link #TOPIC} 主题。
 * 被 {@link com.gov.application.service.impl.ProcessBizServiceImpl} 等业务服务调用，
 * 在审批流程节点流转后推送异步通知（待办提醒、通过通知、评价邀请等）。
 * </p>
 *
 * <h3>事务安全消息</h3>
 * 若调用方处于 Spring 事务中（{@code @Transactional} 方法内），
 * 本类会通过 {@link TransactionSynchronizationManager} 注册 afterCommit 回调，
 * 等事务真正提交成功后才发送消息，避免「消息已发、事务随后回滚」的数据不一致。
 * 非事务场景下则立即发送。
 *
 * <h3>发送失败处理</h3>
 * 通知属于旁路能力，发送失败不应阻断主业务流程。
 * 因此 catch 块只打 error 日志（显式标记消息已丢失便于后续对账补偿），
 * 不向上抛出异常。
 *
 * @see NotifyConsumer
 * @see NotifyMessage
 */
@Component
public class NotifyProducer {

    private static final Logger log = LoggerFactory.getLogger(NotifyProducer.class);

    public static final String TOPIC = "gov-notify-topic";

    @Autowired
    private RocketMQTemplate rocketMQTemplate;

    /**
     * 发送通知。
     *
     * <p>★ 若当前处于事务中，只登记 afterCommit 回调，等事务**提交成功后**才真正投递。
     * 原实现直接在事务内发送，会出现「消息已发出、业务事务随后回滚」的不一致。
     */
    public void send(NotifyMessage msg) {
        if (TransactionSynchronizationManager.isSynchronizationActive()) {
            TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
                @Override
                public void afterCommit() {
                    doSend(msg);
                }
            });
        } else {
            doSend(msg);
        }
    }

    private void doSend(NotifyMessage msg) {
        try {
            rocketMQTemplate.convertAndSend(TOPIC, msg);
            log.info("通知已发送: type={}, bizId={}, receiver={}",
                    msg.getType(), msg.getBizId(), msg.getReceiver());
        } catch (Exception e) {
            // 通知不阻断主流程，但绝不能静默失败：这里显式标记消息已丢失，便于对账补偿
            log.error("通知发送失败，消息已丢失（需补偿）: type={}, bizId={}, receiver={}",
                    msg.getType(), msg.getBizId(), msg.getReceiver(), e);
        }
    }
}