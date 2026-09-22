package com.gov.application.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.application.entity.Dept;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DeptMapper extends BaseMapper<Dept> {
}