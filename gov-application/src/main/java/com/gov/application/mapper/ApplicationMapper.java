package com.gov.application.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.application.entity.Application;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface ApplicationMapper extends BaseMapper<Application> {

    @Select("SELECT status, COUNT(*) AS cnt FROM t_application " +
            "WHERE tenant_id = #{tenantId} " +
            "GROUP BY status")
    List<Map<String, Object>> groupByStatus(@Param("tenantId") String tenantId);

    @Select("SELECT DATE(create_time) AS day, COUNT(*) AS cnt FROM t_application " +
            "WHERE tenant_id = #{tenantId} AND create_time >= #{start} AND create_time < #{end} " +
            "GROUP BY DATE(create_time)")
    List<Map<String, Object>> groupByDate(@Param("tenantId") String tenantId,
                                          @Param("start") LocalDateTime start,
                                          @Param("end") LocalDateTime end);
}