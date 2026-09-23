package com.gov.application.service;

import com.gov.application.entity.Guide;

import java.util.List;
import java.util.Map;

public interface GuideService {

    Map<String, Object> page(int page, int size, String keyword, String category);

    List<String> listCategories();

    Guide getById(Long id);

    Long create(Guide guide);

    void update(Guide guide);

    void delete(Long id);

    void toggleStatus(Long id, Integer status);
}