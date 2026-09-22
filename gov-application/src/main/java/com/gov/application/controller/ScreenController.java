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
        Map<String, Object> overview = new HashMap<>();
        Long totalApplications = applicationMapper.selectCount(new LambdaQueryWrapper<>());
        Long pendingTasks = taskService.createTaskQuery()
                .taskTenantId(tenantId).count();
        Long userCount = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getTenantId, tenantId)
                        .eq(SysUser::getStatus, 1));
        Long todayApplications = applicationMapper.selectCount(
                new LambdaQueryWrapper<Application>()
                        .ge(Application::getCreateTime, today.atStartOfDay()));

        Long approved = applicationMapper.selectCount(
                new LambdaQueryWrapper<Application>()
                        .eq(Application::getStatus, "APPROVED"));
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

        // ============ 2. 近 7 天趋势 ============
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM-dd");
        List<String> days = new ArrayList<>();
        List<Long> newTrend = new ArrayList<>();
        List<Long> doneTrend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            LocalDateTime start = d.atStartOfDay();
            LocalDateTime end = d.plusDays(1).atStartOfDay();

            days.add(d.format(fmt));
            newTrend.add(applicationMapper.selectCount(
                    new LambdaQueryWrapper<Application>()
                            .ge(Application::getCreateTime, start)
                            .lt(Application::getCreateTime, end)));
            doneTrend.add(operLogMapper.selectCount(
                    new LambdaQueryWrapper<OperLog>()
                            .ge(OperLog::getCreateTime, start)
                            .lt(OperLog::getCreateTime, end)
                            .eq(OperLog::getResult, 1)));
        }
        Map<String, Object> trend = new HashMap<>();
        trend.put("days", days);
        trend.put("newApplications", newTrend);
        trend.put("completed", doneTrend);
        data.put("trend", trend);

        // ============ 3. 事项状态分布 ============
        List<Map<String, Object>> statusDist = new ArrayList<>();
        statusDist.add(buildStatusItem("草稿", "DRAFT", "#909399"));
        statusDist.add(buildStatusItem("待审批", "PENDING", "#e6a23c"));
        statusDist.add(buildStatusItem("已通过", "APPROVED", "#67c23a"));
        statusDist.add(buildStatusItem("已驳回", "REJECTED", "#f56c6c"));
        data.put("statusDist", statusDist);

        // ============ 4. 部门办件排名 ============
        List<Dept> depts = deptMapper.selectList(new LambdaQueryWrapper<>());
        Map<Long, String> deptNameMap = depts.stream()
                .collect(Collectors.toMap(
                        Dept::getId,
                        d -> d.getDeptName() == null ? "未命名" : d.getDeptName(),
                        (a, b) -> a));

        List<Application> allApps = applicationMapper.selectList(new LambdaQueryWrapper<>());
        Map<Long, Long> deptCountMap = allApps.stream()
                .filter(a -> a.getDeptId() != null)
                .collect(Collectors.groupingBy(Application::getDeptId, Collectors.counting()));

        List<Map<String, Object>> deptRank = deptCountMap.entrySet().stream()
                .map(e -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", deptNameMap.getOrDefault(e.getKey(), "未知部门"));
                    m.put("value", e.getValue());
                    return m;
                })
                .sorted((a, b) -> Long.compare(
                        ((Number) b.get("value")).longValue(),
                        ((Number) a.get("value")).longValue()))
                .limit(5)
                .collect(Collectors.toList());
        data.put("deptRank", deptRank);

        // ============ 5. 24 小时办件分布 ============
        List<Long> hourDist = new ArrayList<>();
        for (int h = 0; h < 24; h++) {
            LocalDateTime hs = today.atTime(h, 0);
            LocalDateTime he = hs.plusHours(1);
            hourDist.add(applicationMapper.selectCount(
                    new LambdaQueryWrapper<Application>()
                            .ge(Application::getCreateTime, hs)
                            .lt(Application::getCreateTime, he)));
        }
        data.put("hourDist", hourDist);

        // ============ 6. 预约取号 ============
        Map<String, Object> appointmentStat = new HashMap<>();
        appointmentStat.put("todayTotal", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)));
        appointmentStat.put("todayBooked", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)
                        .eq(Appointment::getStatus, "BOOKED")));
        appointmentStat.put("todayChecked", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)
                        .eq(Appointment::getStatus, "CHECKED")));
        appointmentStat.put("todayDone", appointmentMapper.selectCount(
                new LambdaQueryWrapper<Appointment>()
                        .eq(Appointment::getAppointDate, today)
                        .eq(Appointment::getStatus, "DONE")));
        data.put("appointment", appointmentStat);

        // ============ 7. 好差评 ============
        Map<String, Object> evaluationStat = new HashMap<>();
        Long evalTotal = evaluationMapper.selectCount(new LambdaQueryWrapper<>());
        Long goodCount = evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>().ge(Evaluation::getScore, 4));
        Long badCount = evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>().eq(Evaluation::getIsBad, 1));
        Long pendingRectify = evaluationMapper.selectCount(
                new LambdaQueryWrapper<Evaluation>()
                        .eq(Evaluation::getRectifyStatus, "PENDING"));
        evaluationStat.put("total", evalTotal);
        evaluationStat.put("goodCount", goodCount);
        evaluationStat.put("badCount", badCount);
        evaluationStat.put("pendingRectify", pendingRectify);
        evaluationStat.put("goodRate", evalTotal == 0 ? 0 :
                Math.round(goodCount * 100.0 / evalTotal));
        data.put("evaluation", evaluationStat);

        // ============ 8. 电子证照 ============
        Map<String, Object> licenseStat = new HashMap<>();
        licenseStat.put("total", licenseMapper.selectCount(new LambdaQueryWrapper<>()));
        licenseStat.put("valid", licenseMapper.selectCount(
                new LambdaQueryWrapper<License>().eq(License::getStatus, "VALID")));
        licenseStat.put("revoked", licenseMapper.selectCount(
                new LambdaQueryWrapper<License>().eq(License::getStatus, "REVOKED")));
        licenseStat.put("thisMonth", licenseMapper.selectCount(
                new LambdaQueryWrapper<License>()
                        .ge(License::getCreateTime,
                                today.withDayOfMonth(1).atStartOfDay())));
        data.put("license", licenseStat);

        // ============ 9. 办事指南 ============
        Map<String, Object> guideStat = new HashMap<>();
        Long guideTotal = guideMapper.selectCount(new LambdaQueryWrapper<>());
        guideStat.put("total", guideTotal);
        guideStat.put("enabled", guideMapper.selectCount(
                new LambdaQueryWrapper<Guide>().eq(Guide::getStatus, 1)));
        long categoryCount = guideMapper.selectList(new LambdaQueryWrapper<>()).stream()
                .map(Guide::getCategory)
                .filter(c -> c != null && !c.isEmpty())
                .distinct()
                .count();
        guideStat.put("categoryCount", categoryCount);
        data.put("guide", guideStat);

        // ============ 10. 咨询投诉 ============
        Map<String, Object> consultStat = new HashMap<>();
        consultStat.put("total", consultMapper.selectCount(new LambdaQueryWrapper<>()));
        consultStat.put("pending", consultMapper.selectCount(
                new LambdaQueryWrapper<Consult>().eq(Consult::getStatus, "PENDING")));
        consultStat.put("processing", consultMapper.selectCount(
                new LambdaQueryWrapper<Consult>().eq(Consult::getStatus, "PROCESSING")));
        consultStat.put("done", consultMapper.selectCount(
                new LambdaQueryWrapper<Consult>().eq(Consult::getStatus, "DONE")));
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

    private Map<String, Object> buildStatusItem(String name, String status, String color) {
        Map<String, Object> m = new HashMap<>();
        m.put("name", name);
        m.put("value", applicationMapper.selectCount(
                new LambdaQueryWrapper<Application>()
                        .eq(Application::getStatus, status)));
        m.put("color", color);
        return m;
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