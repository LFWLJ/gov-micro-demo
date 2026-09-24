package com.gov.application.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.application.entity.SensitiveWord;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SensitiveWordMapper extends BaseMapper<SensitiveWord> {
}