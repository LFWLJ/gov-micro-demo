package com.gov.application.service;

import com.gov.application.entity.SysDict;
import com.gov.application.entity.SysDictType;

import java.util.List;
import java.util.Map;

public interface DictService {

    List<Map<String, Object>> listTypes();

    List<SysDict> listByType(String dictType);

    List<SysDict> listByTypeCached(String dictType);

    Long createType(SysDictType type);

    Long create(SysDict dict);

    void update(SysDict dict);

    void delete(Long id);
}