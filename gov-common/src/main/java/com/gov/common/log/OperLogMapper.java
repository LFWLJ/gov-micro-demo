package com.gov.common.log;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 操作日志 Mapper
 * <p>
 * 继承 MyBatis-Plus {@link BaseMapper} 获得基础 CRUD 能力，
 * 额外提供按日期分组的统计查询（用于大屏 / 报表展示）。
 * </p>
 */
@Mapper
public interface OperLogMapper extends BaseMapper<OperLog> {

    /**
     * 按天统计指定租户在时间区间内的操作日志数量
     *
     * @param tenantId 租户标识
     * @param start    统计起始时间（含）
     * @param end      统计结束时间（不含）
     * @return 列表，每项包含 {@code day}（日期字符串）和 {@code cnt}（当日条数）
     */
    @Select("SELECT DATE(create_time) AS day, COUNT(*) AS cnt FROM sys_oper_log " +
            "WHERE tenant_id = #{tenantId} AND create_time >= #{start} AND create_time < #{end} " +
            "GROUP BY DATE(create_time)")
    List<Map<String, Object>> groupByDate(@Param("tenantId") String tenantId,
                                          @Param("start") LocalDateTime start,
                                          @Param("end") LocalDateTime end);
}