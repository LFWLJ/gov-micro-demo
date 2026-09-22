package com.gov.common.log;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.mybatis.spring.annotation.MapperScan;

@Mapper
@MapperScan({"com.gov.application.mapper", "com.gov.common.log"})
public interface OperLogMapper extends BaseMapper<OperLog> {
}