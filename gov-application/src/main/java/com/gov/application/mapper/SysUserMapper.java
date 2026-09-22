package com.gov.application.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.application.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {
}