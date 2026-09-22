package com.gov.application.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.Notify;
import com.gov.application.mapper.NotifyMapper;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
public class NotifyService {

    @Autowired
    private NotifyMapper notifyMapper;

    /** 分页查询当前用户消息 */
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

    /** 未读数量 */
    public Long unreadCount(String receiver) {
        return notifyMapper.selectCount(
                new LambdaQueryWrapper<Notify>()
                        .eq(Notify::getReceiver, receiver)
                        .eq(Notify::getIsRead, 0));
    }

    /** 标记已读 */
    public void read(Long id, String receiver) {
        Notify notify = notifyMapper.selectById(id);
        if (notify == null) return;
        if (!receiver.equals(notify.getReceiver())) return;

        notify.setIsRead(1);
        notify.setReadTime(LocalDateTime.now());
        notifyMapper.updateById(notify);
    }

    /** 全部已读 */
    public void readAll(String receiver) {
        Notify update = new Notify();
        update.setIsRead(1);
        update.setReadTime(LocalDateTime.now());
        notifyMapper.update(update,
                new LambdaQueryWrapper<Notify>()
                        .eq(Notify::getReceiver, receiver)
                        .eq(Notify::getIsRead, 0));
    }

    /** 删除 */
    public void delete(Long id, String receiver) {
        Notify notify = notifyMapper.selectById(id);
        if (notify == null) return;
        if (!receiver.equals(notify.getReceiver())) return;
        notifyMapper.deleteById(id);
    }

    /** 发送消息（供内部调用） */
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