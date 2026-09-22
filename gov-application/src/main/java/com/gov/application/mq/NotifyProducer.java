package com.gov.application.mq;

import org.apache.rocketmq.spring.core.RocketMQTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class NotifyProducer {

    private static final Logger log = LoggerFactory.getLogger(NotifyProducer.class);

    public static final String TOPIC = "gov-notify-topic";

    @Autowired
    private RocketMQTemplate rocketMQTemplate;

    public void send(NotifyMessage msg) {
        try {
            rocketMQTemplate.convertAndSend(TOPIC, msg);
            log.info("通知已发送: type={}, bizId={}, receiver={}",
                    msg.getType(), msg.getBizId(), msg.getReceiver());
        } catch (Exception e) {
            // 消息发送失败不影响主流程，只记日志
            log.error("通知发送失败", e);
        }
    }
}