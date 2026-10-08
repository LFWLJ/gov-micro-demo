package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Notify;
import com.gov.application.mapper.NotifyMapper;
import com.gov.application.service.NotifyService;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * 站内通知业务实现
 * <p>
 * 基于 MySQL 的轻量级站内消息系统，与 RocketMQ 的异步通知（{@link com.gov.application.mq.NotifyProducer}）互补：
 * MQ 负责跨服务异步事件（短信 / 外部推送），本服务负责前端可拉取的站内通知列表。
 * </p>
 * <p>
 * 所有操作按 receiver 精确过滤（不按用户 ID 加租户隔离，因为 receiver 本身已唯一标识接收人）。
 * 读 / 删 / 标已读均做接收人归属校验，防止越权。
 * </p>
 */
@Service
public class NotifyServiceImpl implements NotifyService {

    @Autowired
    private NotifyMapper notifyMapper;

    /** 分页查询接收人的通知列表，可按已读状态过滤 */
    @Override
    public Map<String, Object> page(int page, int size, String receiver, Integer isRead) {
        LambdaQueryWrapper<Notify> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Notify::getReceiver, receiver);
        if (isRead != null) {
            wrapper.eq(Notify::getIsRead, isRead);
        }
        wrapper.orderByDesc(Notify::getId);

        Page<Notify> p = new Page<>(page, size);
        Page<Notify> result = notifyMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return data;
    }

    /** 查询接收人的未读通知数量（用于角标） */
    @Override
    public Long unreadCount(String receiver) {
        return notifyMapper.selectCount(
                new LambdaQueryWrapper<Notify>()
                        .eq(Notify::getReceiver, receiver)
                        .eq(Notify::getIsRead, 0));
    }

    /** 将单条通知标记为已读（校验归属） */
    @Override
    public void read(Long id, String receiver) {
        Notify notify = notifyMapper.selectById(id);
        if (notify == null) return;
        if (!receiver.equals(notify.getReceiver())) return;

        notify.setIsRead(1);
        notify.setReadTime(LocalDateTime.now());
        notifyMapper.updateById(notify);
    }

    /** 将接收人的所有未读通知一次性标记为已读 */
    @Override
    public void readAll(String receiver) {
        Notify update = new Notify();
        update.setIsRead(1);
        update.setReadTime(LocalDateTime.now());
        notifyMapper.update(update,
                new LambdaQueryWrapper<Notify>()
                        .eq(Notify::getReceiver, receiver)
                        .eq(Notify::getIsRead, 0));
    }

    /** 删除单条通知（校验归属） */
    @Override
    public void delete(Long id, String receiver) {
        Notify notify = notifyMapper.selectById(id);
        if (notify == null) return;
        if (!receiver.equals(notify.getReceiver())) return;
        notifyMapper.deleteById(id);
    }

    /** 发送站内通知（返回通知 ID，供调用方关联业务记录） */
    @Override
    public Long send(String receiver, String title, String content, String type, Long bizId) {
        Notify notify = new Notify();
        notify.setTenantId(TenantContext.get());
        notify.setReceiver(receiver);
        notify.setTitle(title);
        notify.setContent(content);
        notify.setType(type);
        notify.setBizId(bizId);
        notify.setIsRead(0);
        notify.setCreateTime(LocalDateTime.now());
        notifyMapper.insert(notify);
        return notify.getId();
    }
}