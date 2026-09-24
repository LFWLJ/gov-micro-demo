package com.gov.common.log;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface OperLogMapper extends BaseMapper<OperLog> {

    @Select("SELECT DATE(create_time) AS day, COUNT(*) AS cnt FROM sys_oper_log " +
            "WHERE tenant_id = #{tenantId} AND create_time >= #{start} AND create_time < #{end} " +
            "GROUP BY DATE(create_time)")
    List<Map<String, Object>> groupByDate(@Param("tenantId") String tenantId,
                                          @Param("start") LocalDateTime start,
                                          @Param("end") LocalDateTime end);
}