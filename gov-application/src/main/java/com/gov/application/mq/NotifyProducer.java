package com.gov.application.mq;

import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;

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