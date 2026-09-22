package com.gov.application.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.application.entity.Appointment;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AppointmentMapper extends BaseMapper<Appointment> {
}
