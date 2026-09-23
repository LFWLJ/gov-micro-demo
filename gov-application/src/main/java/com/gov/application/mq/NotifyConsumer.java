package com.gov.application.mq;

import com.gov.common.tenant.TenantContext;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@RocketMQMessageListener(
        topic = NotifyProducer.TOPIC,
        consumerGroup = "gov-notify-consumer"
)
public class NotifyConsumer implements RocketMQListener<NotifyMessage> {

    private static final Logger log = LoggerFactory.getLogger(NotifyConsumer.class);

    private static final Map<String, String> TYPE_PREFIX = Map.of(
            "TASK_CREATED", "您有新的待办：",
            "TASK_COMPLETED", "您的任务已完成：",
            "PROCESS_APPROVED", "您的办件已通过：",
            "EVALUATION_INVITE", "请对本次服务进行评价：",
            "CONSULT_CREATED", "有新的咨询投诉待处理："
    );

    @Override
    public void onMessage(NotifyMessage msg) {
        try {
            if (msg.getTenantId() != null) {
                TenantContext.set(msg.getTenantId());
            }
            log.info("【通知消费】type={}, bizId={}, receiver={}, content={}",
                    msg.getType(), msg.getBizId(), msg.getReceiver(), msg.getContent());

            String prefix = TYPE_PREFIX.get(msg.getType());
            if (prefix != null) {
                sendSms(msg.getReceiver(), prefix + msg.getContent());
            } else {
                log.warn("未知通知类型: {}", msg.getType());
            }
        } catch (Exception e) {
            log.error("通知消费异常, type={}, tenantId={}", msg.getType(), msg.getTenantId(), e);
        } finally {
            TenantContext.clear();
        }
    }

    private void sendSms(String receiver, String content) {
        log.info(">>> 【模拟短信】 发送给 {}: {}", receiver, content);
    }
}