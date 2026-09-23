package com.gov.application.service;

import com.gov.application.entity.Dept;

import java.util.List;

public interface DeptService {

    List<Dept> tree();

    List<Long> getSelfAndChildIds(Long deptId);

    Long create(Dept dept);

    void update(Dept dept);

    void delete(Long id);
}