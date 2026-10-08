package com.gov.application.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.api.feign.FileFeignClient;
import com.gov.application.entity.*;
import com.gov.application.mapper.*;
import com.gov.common.log.OperLog;
import com.gov.common.log.OperLogMapper;
import com.gov.common.result.R;
import com.gov.common.tenant.TenantContext;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.flowable.engine.HistoryService;
import org.flowable.engine.TaskService;
import org.flowable.engine.history.HistoricProcessInstance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 数据大屏 HTTP 接口
 * <p>
 * 面向领导驾驶舱的数据总览接口，在单个 {@code GET /overview} 中一次性打包输出：
 * 核心指标（办件总数、待办、审批率、平均办结时长）、近 7 天趋势、状态分布、
 * 部门办件排名、24 小时分布、预约 / 好差评 / 证照 / 指南 / 咨询等各业务模块统计。
 * 文件统计通过 Feign 远程调用 gov-file 服务获取。
 * </p>
 * <p>
 * 注意：本接口一次性查询多个业务表 + Flowable 历史表，数据量大时可能成为性能瓶颈，
 * 生产建议改成定时任务预计算写入独立统计表，本接口只查聚合表。
 * </p>
 */
@Tag(name = "数据大屏")
@RestController
@RequestMapping("/api/screen")
public class ScreenController {

    @Autowired private ApplicationMapper applicationMapper;
    @Autowired private OperLogMapper operLogMapper;
    @Autowired private SysUserMapper sysUserMapper;
    @Autowired private DeptMapper deptMapper;
    @Autowired private AppointmentMapper appointmentMapper;
    @Autowired private EvaluationMapper evaluationMapper;
    @Autowired private LicenseMapper licenseMapper;
    @Autowired private GuideMapper guideMapper;
    @Autowired private ConsultMapper consultMapper;
    @Autowired private ScreenStatMapper screenStatMapper;
    @Autowired private TaskService taskService;
    @Autowired private HistoryService historyService;

    @Autowired(required = false)
    private FileFeignClient fileFeignClient;

    @Operation(summary = "大屏总览")
    @GetMapping("/overview")
    public R<Map<String, Object>> overview() {
        String tenantId = TenantContext.get();
        LocalDate today = LocalDate.now();
        Map<String, Object> data = new HashMap<>();

        // ============ 1. 核心指标 ============
        // 一次分组查询拿到各状态计数，total / approved / statusDist 都从它派生（原来要 6 条 count）
        List<Map<String, Object>> statusRows = screenStatMapper.countApplicationByStatus();
        Map<String, Long> statusCounts = toCountMap(statusRows);
        long totalApplications = sumAll(statusRows);
        long approved = countOf(statusCounts, "APPROVED");

        Map<String, Object> overview = new HashMap<>();
        Long pendingTasks = taskService.createTaskQuery()
                .taskTenantId(tenantId).count();
        Long userCount = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getTenantId, tenantId)
                        .eq(SysUser::getStatus, 1));
        Long todayApplications = applicationMapper.selectCount(
                new LambdaQueryWrapper<Application>()
                        .ge(Application::getCreateTime, today.atStartOfDay()));

        double approvalRate = totalApplications == 0 ? 0 :
                (double) approved / totalApplications;

        List<HistoricProcessInstance> finished = historyService
                .createHistoricProcessInstanceQuery()
                .processInstanceTenantId(tenantId)
                .finished()
                .list();
        double avgHours = 0;
        if (!finished.isEmpty()) {
            long totalMs = finished.stream()
                    .filter(p -> p.getDurationInMillis() != null)
                    .mapToLong(HistoricProcessInstance::getDurationInMillis)
                    .sum();
            avgHours = totalMs / 1000.0 / 3600 / finished.size();
        }

        overview.put("totalApplications", totalApplications);
        overview.put("pendingTasks", pendingTasks);
        overview.put("userCount", userCount);
        overview.put("todayApplications", todayApplications);
        overview.put("approvalRate", Math.round(approvalRate * 100));
        overview.put("avgHours", Math.round(avgHours * 10) / 10.0);
        data.put("overview", overview);

        // ============ 2. 近 7 天趋势（2 条聚合 + Java 补零，替代原来 14 条 count）============
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM-dd");
        LocalDate trendStart = today.minusDays(6);
        Map<String, Long> newByDay = toCountMap(
                screenStatMapper.countApplicationByDay(trendStart.atStartOfDay()));
        Map<String, Long> doneByDay = toCountMap(
                screenStatMapper.countOperLogByDay(trendStart.atStartOfDay()));

        List<String> days = new ArrayList<>();
        List<Long> newTrend = new ArrayList<>();
        List<Long> doneTrend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            String key = d.toString();
            days.add(d.format(fmt));
            newTrend.add(newByDay.getOrDefault(key, 0L));
            doneTrend.add(doneByDay.getOrDefault(key, 0L));
        }
        Map<String, Object> trend = new HashMap<>();
        trend.put("days", days);
        trend.put("newApplications", newTrend);
        trend.put("completed", doneTrend);
        data.put("trend", trend);

        // ============ 3. 事项状态分布 ============
        List<Map<String, Object>> statusDist = new ArrayList<>();
        statusDist.add(buildStatusItem("草稿", "DRAFT", "#909399", statusCounts));
        statusDist.add(buildStatusItem("待审批", "PENDING", "#e6a23c", statusCounts));
        statusDist.add(buildStatusItem("已通过", "APPROVED", "#67c23a", statusCounts));
        statusDist.add(buildStatusItem("已驳回", "REJECTED", "#f56c6c", statusCounts));
        data.put("statusDist", statusDist);

        // ============ 4. 部门办件排名（聚合 Top5，替代"整表捞进内存再分组"）============
        List<Dept> depts = deptMapper.selectList(new LambdaQueryWrapper<>());
        Map<Long, String> deptNameMap = depts.stream()
                .collect(Collectors.toMap(
                        Dept::getId,
                        d -> d.getDeptName() == null ? "未命名" : d.getDeptName(),
                        (a, b) -> a));

        List<Map<String, Object>> deptRank = new ArrayList<>();
        for (Map<String, Object> row : screenStatMapper.topDeptByApplication(5)) {
            Object k = row.get("k");
            if (k == null) continue;
            Map<String, Object> m = new HashMap<>();
            m.put("name", deptNameMap.getOrDefault(((Number) k).longValue(), "未知部门"));
            m.put("value", row.get("v") == null ? 0L : ((Number) row.get("v")).longValue());
            deptRank.add(m);
        }
        data.put("deptRank", deptRank);

        // ============ 5. 24 小时办件分布（1 条聚合替代 24 条 count）============
        Map<String, Long> byHour = toCountMap(screenStatMapper.countApplicationByHour(
                today.atStartOfDay(), today.plusDays(1).atStartOfDay()));
        List<Long> hourDist = new ArrayList<>();
        for (int h = 0; h < 24; h++) {
            hourDist.add(byHour.getOrDefault(String.valueOf(h), 0L));
        }
        data.put("hourDist", hourDist);

        // ============ 6. 预约取号（1 条聚合替代 4 条 count）============
        List<Map<String, Object>> apptRows = screenStatMapper.countAppointmentByStatus(today);
        Map<String, Long> apptByStatus = toCountMap(apptRows);
        Map<String, Object> appointmentStat = new HashMap<>();
        appointmentStat.put("todayTotal", sumAll(apptRows));
        appointmentStat.put("todayBooked", countOf(apptByStatus, "BOOKED"));
        appointmentStat.put("todayChecked", countOf(apptByStatus, "CHECKED"));
        appointmentStat.put("todayDone", countOf(apptByStatus, "DONE"));
        data.put("appointment", appointmentStat);

        // ============ 7. 好差评 ============
        // 这四个指标维度互不相同（总/评分/是否差评/整改状态），无法用一条 GROUP BY 表达；
        // 而 CASE/CAST 组合会让租户拦截器的 JSqlParser 解析失败，故保持 4 条简单 count。
        Map<String, Object> evaluationStat = new HashMap<>();
        Long evalTotal = evaluationMapper.selectCount(new LambdaQueryWrapper<>());
        Long goodCount = evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>().ge(Evaluation::getScore, 4));
        evaluationStat.put("total", evalTotal);
        evaluationStat.put("goodCount", goodCount);
        evaluationStat.put("badCount", evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>().eq(Evaluation::getIsBad, 1)));
        evaluationStat.put("pendingRectify", evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>()
                        .eq(Evaluation::getRectifyStatus, "PENDING")));
        evaluationStat.put("goodRate", evalTotal == 0 ? 0 :
                Math.round(goodCount * 100.0 / evalTotal));
        data.put("evaluation", evaluationStat);

        // ============ 8. 电子证照（1 条分组 + 1 条 count，替代原 4 条）============
        List<Map<String, Object>> licRows = screenStatMapper.countLicenseByStatus();
        Map<String, Long> licByStatus = toCountMap(licRows);
        Map<String, Object> licenseStat = new HashMap<>();
        licenseStat.put("total", sumAll(licRows));
        licenseStat.put("valid", countOf(licByStatus, "VALID"));
        licenseStat.put("revoked", countOf(licByStatus, "REVOKED"));
        licenseStat.put("thisMonth", licenseMapper.selectCount(
                new LambdaQueryWrapper<License>()
                        .ge(License::getCreateTime, today.withDayOfMonth(1).atStartOfDay())));
        data.put("license", licenseStat);

        // ============ 9. 办事指南（1 条分组 + 1 条 count distinct，替代原 3 条）============
        List<Map<String, Object>> guideRows = screenStatMapper.countGuideByStatus();
        Map<String, Long> guideByStatus = toCountMap(guideRows);
        long guideTotal = sumAll(guideRows);
        Long catCount = screenStatMapper.countGuideCategory();
        Map<String, Object> guideStat = new HashMap<>();
        guideStat.put("total", guideTotal);
        // guide.status 是整型 1/0，分组键经 String.valueOf 归一化后为 "1"
        guideStat.put("enabled", countOf(guideByStatus, "1"));
        guideStat.put("categoryCount", catCount == null ? 0L : catCount);
        data.put("guide", guideStat);

        // ============ 10. 咨询投诉（1 条分组替代原 4 条 count）============
        List<Map<String, Object>> consultRows = screenStatMapper.countConsultByStatus();
        Map<String, Long> consultByStatus = toCountMap(consultRows);
        Map<String, Object> consultStat = new HashMap<>();
        consultStat.put("total", sumAll(consultRows));
        consultStat.put("pending", countOf(consultByStatus, "PENDING"));
        consultStat.put("processing", countOf(consultByStatus, "PROCESSING"));
        consultStat.put("done", countOf(consultByStatus, "DONE"));
        data.put("consult", consultStat);

        // ============ 11. 文件（Feign 调 gov-file）============
        Map<String, Object> fileStat = new HashMap<>();
        try {
            if (fileFeignClient != null) {
                R<Map<String, Object>> fileResult = fileFeignClient.getStats();
                if (fileResult.getCode() == 200 && fileResult.getData() != null) {
                    fileStat = fileResult.getData();
                    Long size = ((Number) fileStat.getOrDefault("totalSize", 0)).longValue();
                    fileStat.put("totalSizeText", formatSize(size));
                }
            }
        } catch (Exception e) {
            fileStat.put("total", 0);
            fileStat.put("totalSize", 0);
            fileStat.put("totalSizeText", "0 B");
        }
        data.put("file", fileStat);

        // ============ 12. 实时动态 ============
        List<OperLog> logs = operLogMapper.selectList(
                new LambdaQueryWrapper<OperLog>()
                        .orderByDesc(OperLog::getId)
                        .last("LIMIT 15"));
        List<Map<String, Object>> recentLogs = logs.stream().map(l -> {
            Map<String, Object> m = new HashMap<>();
            m.put("time", l.getCreateTime());
            m.put("operation", l.getOperation());
            m.put("module", l.getModule());
            m.put("result", l.getResult());
            return m;
        }).collect(Collectors.toList());
        data.put("recentLogs", recentLogs);

        // ============ 13. 各模块业务量对比 ============
        List<Map<String, Object>> moduleStats = new ArrayList<>();
        moduleStats.add(buildModuleStat("办件", totalApplications));
        moduleStats.add(buildModuleStat("预约", appointmentStat.get("todayTotal")));
        moduleStats.add(buildModuleStat("证照", licenseStat.get("total")));
        moduleStats.add(buildModuleStat("指南", guideTotal));
        moduleStats.add(buildModuleStat("咨询", consultStat.get("total")));
        moduleStats.add(buildModuleStat("评价", evalTotal));
        data.put("moduleStats", moduleStats);

        return R.ok(data);
    }

    private Map<String, Object> buildStatusItem(String name, String status, String color,
                                                Map<String, Long> statusCounts) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", name);
        m.put("value", countOf(statusCounts, status));
        m.put("color", color);
        return m;
    }

    /** 把 (k, v) 形式的分组计数转成 Map；键为 null 的分组不参与按名取用（但仍计入 sumAll） */
    private Map<String, Long> toCountMap(List<Map<String, Object>> rows) {
        Map<String, Long> map = new HashMap<>();
        if (rows == null) return map;
        for (Map<String, Object> row : rows) {
            Object k = row.get("k");
            if (k == null) continue;
            Object v = row.get("v");
            map.put(String.valueOf(k), v == null ? 0L : ((Number) v).longValue());
        }
        return map;
    }

    /** 汇总所有分组的计数（含键为 null 的分组），等价于原来的无条件 count */
    private long sumAll(List<Map<String, Object>> rows) {
        long sum = 0;
        if (rows == null) return 0;
        for (Map<String, Object> row : rows) {
            Object v = row.get("v");
            if (v != null) sum += ((Number) v).longValue();
        }
        return sum;
    }

    private long countOf(Map<String, Long> counts, String key) {
        return counts.getOrDefault(key, 0L);
    }

    private Map<String, Object> buildModuleStat(String name, Object value) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", name);
        m.put("value", value);
        return m;
    }

    private String formatSize(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        if (bytes < 1024 * 1024 * 1024) return String.format("%.2f MB", bytes / 1024.0 / 1024);
        return String.format("%.2f GB", bytes / 1024.0 / 1024 / 1024);
    }
}