package com.gov.application.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 数据大屏专用的聚合查询。
 *
 * <p>背景：{@code ScreenController#overview} 原先在循环里逐条 count
 * （近 7 天趋势 14 条 + 24 小时分布 24 条 + 状态分布 4 条 …），单次请求发出 70 条 SQL。
 * 这里改成「一次查询返回一组分组计数」，由 Java 侧补零/求和，语义不变。
 *
 * <p><b>⚠️ 编写本类 SQL 的硬约束：必须保持朴素。</b>
 * 这些表都受 MyBatis-Plus 租户拦截器管辖，拦截器用 JSqlParser 解析并改写每条 SQL 追加
 * {@code tenant_id} 条件。实测 {@code CAST(COALESCE(SUM(CASE WHEN ... END), 0) AS SIGNED)}
 * 这类嵌套写法会让 JSqlParser 抛 {@code ParseException: unexpected token ","}，
 * 导致整个接口 500。因此这里只使用
 * 「{@code SELECT 单列 AS k, COUNT(*) AS v ... GROUP BY 单列}」与 {@code COUNT(DISTINCT 单列)}
 * 这两种已被验证可安全改写的形态；需要多指标时在 Java 侧聚合，不要塞进一条 SQL。
 *
 * <p>分隔说明：分组查询返回 (k, v) 两列，键值统一在 Java 侧归一化。
 */
@Mapper
public interface ScreenStatMapper {

    /** 事项按状态分组计数（同时用于 total / approved / statusDist） */
    @Select("SELECT status AS k, COUNT(*) AS v FROM t_application GROUP BY status")
    List<Map<String, Object>> countApplicationByStatus();

    /** 事项按天分组计数（近 N 天新增趋势） */
    @Select("SELECT DATE_FORMAT(create_time, '%Y-%m-%d') AS k, COUNT(*) AS v " +
            "FROM t_application WHERE create_time >= #{start} GROUP BY k")
    List<Map<String, Object>> countApplicationByDay(@Param("start") LocalDateTime start);

    /** 任务完成量按天分组计数（取操作日志中的成功记录） */
    @Select("SELECT DATE_FORMAT(create_time, '%Y-%m-%d') AS k, COUNT(*) AS v " +
            "FROM sys_oper_log WHERE result = 1 AND create_time >= #{start} GROUP BY k")
    List<Map<String, Object>> countOperLogByDay(@Param("start") LocalDateTime start);

    /** 今日事项按小时分组计数 */
    @Select("SELECT HOUR(create_time) AS k, COUNT(*) AS v FROM t_application " +
            "WHERE create_time >= #{start} AND create_time < #{end} GROUP BY k")
    List<Map<String, Object>> countApplicationByHour(@Param("start") LocalDateTime start,
                                                     @Param("end") LocalDateTime end);

    /** 部门办件量 Top N（避免把整张表捞进内存再分组） */
    @Select("SELECT dept_id AS k, COUNT(*) AS v FROM t_application " +
            "WHERE dept_id IS NOT NULL GROUP BY dept_id ORDER BY v DESC LIMIT #{limit}")
    List<Map<String, Object>> topDeptByApplication(@Param("limit") int limit);

    /** 指定日期预约按状态分组计数 */
    @Select("SELECT status AS k, COUNT(*) AS v FROM t_appointment " +
            "WHERE appoint_date = #{date} GROUP BY status")
    List<Map<String, Object>> countAppointmentByStatus(@Param("date") LocalDate date);

    /** 证照按状态分组计数（total / valid / revoked 由 Java 侧派生） */
    @Select("SELECT status AS k, COUNT(*) AS v FROM t_license GROUP BY status")
    List<Map<String, Object>> countLicenseByStatus();

    /** 办事指南按状态分组计数（total / enabled 由 Java 侧派生） */
    @Select("SELECT status AS k, COUNT(*) AS v FROM t_guide GROUP BY status")
    List<Map<String, Object>> countGuideByStatus();

    /** 办事指南分类数（替代原来把整表 selectList 进内存 distinct） */
    @Select("SELECT COUNT(DISTINCT category) FROM t_guide " +
            "WHERE category IS NOT NULL AND category != ''")
    Long countGuideCategory();

    /** 咨询投诉按状态分组计数（total / pending / processing / done 由 Java 侧派生） */
    @Select("SELECT status AS k, COUNT(*) AS v FROM t_consult GROUP BY status")
    List<Map<String, Object>> countConsultByStatus();
}
