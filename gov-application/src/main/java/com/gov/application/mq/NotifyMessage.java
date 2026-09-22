package com.gov.application.mq;

import java.io.Serializable;

public class NotifyMessage implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 消息类型 */
    private String type;

    /** 业务ID（事项ID、评价ID、工单ID） */
    private Long bizId;

    /** 业务编号（流程实例ID、办件号） */
    private String bizKey;

    /** 租户ID */
    private String tenantId;

    /** 接收人 */
    private String receiver;

    /** 通知内容 */
    private String content;

    /** 时间戳 */
    private Long timestamp;

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Long getBizId() { return bizId; }
    public void setBizId(Long bizId) { this.bizId = bizId; }

    public String getBizKey() { return bizKey; }
    public void setBizKey(String bizKey) { this.bizKey = bizKey; }

    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }

    public String getReceiver() { return receiver; }
    public void setReceiver(String receiver) { this.receiver = receiver; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Long getTimestamp() { return timestamp; }
    public void setTimestamp(Long timestamp) { this.timestamp = timestamp; }

    /**
     * 静态工厂方法
     */
    public static NotifyMessage of(String type, Long bizId, String bizKey,
                                   String tenantId, String receiver, String content) {
        NotifyMessage msg = new NotifyMessage();
        msg.setType(type);
        msg.setBizId(bizId);
        msg.setBizKey(bizKey);
        msg.setTenantId(tenantId);
        msg.setReceiver(receiver);
        msg.setContent(content);
        msg.setTimestamp(System.currentTimeMillis());
        return msg;
    }
}