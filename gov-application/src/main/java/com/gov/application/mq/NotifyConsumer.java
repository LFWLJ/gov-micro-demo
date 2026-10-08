package com.gov.application.mq;

import com.gov.common.tenant.TenantContext;
import org.apache.rocketmq.spring.annotation.RocketMQMessageListener;
import org.apache.rocketmq.spring.core.RocketMQListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * RocketMQ 通知消费者
 * <p>
 * 订阅 {@link NotifyProducer#TOPIC} 主题，消费 {@link NotifyMessage} 消息。
 * 实际业务中此处应对接短信网关 / 邮件服务 / App 推送通道，
 * 当前为演示目的，仅打印模拟短信日志。
 * </p>
 *
 * <h3>设计要点</h3>
 * <ul>
 *   <li><b>租户上下文恢复</b>：从消息体的 {@code tenantId} 字段恢复
 *       {@link TenantContext}，保证后续如要查库仍能走多租户隔离</li>
 *   <li><b>异常重抛触发重试</b>：catch 块末尾 <b>必须重新抛出异常</b>，
 *       RocketMQ 收到异常才会进行重试；吞掉异常等于直接 ack，消息会被永久丢弃</li>
 *   <li><b>at-least-once 语义</b>：若业务要求严格幂等，应引入 msgId + Redis 去重，
 *       防止重复消费造成重复通知</li>
 * </ul>
 *
 * @see NotifyProducer
 * @see NotifyMessage
 */
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
            // ★ 必须重抛：RocketMQ 只有收到异常才会重试，吞掉异常等于直接 ack，
            //   消息会被永久丢弃（消费方是做通知，重试可能重复发送，
            //   若要求严格幂等，应引入 msgId + Redis 去重，当前实现按 at-least-once 处理）。
            throw new RuntimeException("通知消费失败，触发重试: " + msg.getType(), e);
        } finally {
            TenantContext.clear();
        }
    }

    private void sendSms(String receiver, String content) {
        log.info(">>> 【模拟短信】 发送给 {}: {}", receiver, content);
    }
}