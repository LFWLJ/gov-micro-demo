package com.gov.application.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.Application;
import com.gov.application.entity.SysUser;
import com.gov.application.mapper.ApplicationMapper;
import com.gov.application.mapper.SysUserMapper;
import com.gov.common.log.OperLog;
import com.gov.common.log.OperLogMapper;
import com.gov.common.result.R;
import com.gov.common.tenant.TenantContext;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.flowable.engine.TaskService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "仪表盘")
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private ApplicationMapper applicationMapper;

    @Autowired
    private OperLogMapper operLogMapper;

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private TaskService taskService;

    @Operation(summary = "首页统计")
    @GetMapping("/stats")
    public R<Map<String, Object>> stats() {
        String tenantId = TenantContext.get();
        Map<String, Object> data = new HashMap<>();

        // 1. 事项总数
        Long totalApplications = applicationMapper.selectCount(null);
        data.put("totalApplications", totalApplications);

        // 2. 各状态事项数
        Map<String, Long> statusCount = new HashMap<>();
        statusCount.put("DRAFT", countByStatus("DRAFT"));
        statusCount.put("PENDING", countByStatus("PENDING"));
        statusCount.put("APPROVED", countByStatus("APPROVED"));
        data.put("statusCount", statusCount);

        // 3. 待办任务数（Flowable）
        Long pendingTasks = taskService.createTaskQuery()
                .taskTenantId(tenantId)
                .count();
        data.put("pendingTasks", pendingTasks);

        // 4. 用户数
        Long userCount = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getTenantId, tenantId)
                        .eq(SysUser::getStatus, 1));
        data.put("userCount", userCount);

        // 5. 操作日志数
        Long logCount = operLogMapper.selectCount(null);
        data.put("logCount", logCount);

        // 6. 最近 7 天事项趋势
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM-dd");
        List<Map<String, Object>> trend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.plusDays(1).atStartOfDay();

            Long count = applicationMapper.selectCount(
                    new LambdaQueryWrapper<Application>()
                            .ge(Application::getCreateTime, start)
                            .lt(Application::getCreateTime, end));

            Map<String, Object> item = new HashMap<>();
            item.put("date", date.format(fmt));
            item.put("count", count);
            trend.add(item);
        }
        data.put("trend", trend);

        // 7. 最近 7 天日志趋势
        List<Map<String, Object>> logTrend = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            LocalDateTime start = date.atStartOfDay();
            LocalDateTime end = date.plusDays(1).atStartOfDay();

            Long count = operLogMapper.selectCount(
                    new LambdaQueryWrapper<OperLog>()
                            .ge(OperLog::getCreateTime, start)
                            .lt(OperLog::getCreateTime, end));

            Map<String, Object> item = new HashMap<>();
            item.put("date", date.format(fmt));
            item.put("count", count);
            logTrend.add(item);
        }
        data.put("logTrend", logTrend);

        return R.ok(data);
    }

    private Long countByStatus(String status) {
        return applicationMapper.selectCount(
                new LambdaQueryWrapper<Application>()
                        .eq(Application::getStatus, status));
    }
}