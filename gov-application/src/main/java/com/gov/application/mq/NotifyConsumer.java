package com.gov.application.mq;

import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
@RocketMQMessageListener(
        topic = NotifyProducer.TOPIC,
        consumerGroup = "gov-notify-consumer"
)
public class NotifyConsumer implements RocketMQListener<NotifyMessage> {

    private static final Logger log = LoggerFactory.getLogger(NotifyConsumer.class);

    @Override
    public void onMessage(NotifyMessage msg) {
        log.info("【通知消费】type={}, bizId={}, receiver={}, content={}",
                msg.getType(), msg.getBizId(), msg.getReceiver(), msg.getContent());

        switch (msg.getType()) {
            case "TASK_CREATED":
                sendSms(msg.getReceiver(), "您有新的待办：" + msg.getContent());
                break;
            case "TASK_COMPLETED":
                sendSms(msg.getReceiver(), "您的任务已完成：" + msg.getContent());
                break;
            case "PROCESS_APPROVED":
                sendSms(msg.getReceiver(), "您的办件已通过：" + msg.getContent());
                break;
            case "EVALUATION_INVITE":
                sendSms(msg.getReceiver(), "请对本次服务进行评价：" + msg.getContent());
                break;
            case "CONSULT_CREATED":
                sendSms(msg.getReceiver(), "有新的咨询投诉待处理：" + msg.getContent());
                break;
            default:
                log.warn("未知通知类型: {}", msg.getType());
        }
    }

    /** 模拟发短信 */
    private void sendSms(String receiver, String content) {
        log.info(">>> 【模拟短信】 发送给 {}: {}", receiver, content);
        // 真实场景：调用短信网关 API
    }
}