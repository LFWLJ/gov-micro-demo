package com.gov.application.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.application.entity.ApplicationLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ApplicationLogMapper extends BaseMapper<ApplicationLog> {
}