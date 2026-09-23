package com.gov.application.service;

import java.util.Map;

public interface NotifyService {

    Map<String, Object> page(int page, int size, String receiver, Integer isRead);

    Long unreadCount(String receiver);

    void read(Long id, String receiver);

    void readAll(String receiver);

    void delete(Long id, String receiver);

    Long send(String receiver, String title, String content, String type, Long bizId);
}