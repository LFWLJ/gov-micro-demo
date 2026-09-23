package com.gov.application.service;

import java.util.Map;

public interface ConsultService {

    Map<String, Object> page(int page, int size, String keyword,
                             String type, String status);

    Long create(com.gov.application.entity.Consult consult);

    void reply(Long id, String handler, String reply);

    void close(Long id);

    void delete(Long id);

    Map<String, Object> stats();
}