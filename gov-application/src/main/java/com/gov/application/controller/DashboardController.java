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
import java.util.LinkedHashMap;
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

        // 2. 各状态事项数（1 条 SQL 代替 3 条）
        Map<String, Long> statusCount = new HashMap<>();
        statusCount.put("DRAFT", 0L);
        statusCount.put("PENDING", 0L);
        statusCount.put("APPROVED", 0L);
        for (Map<String, Object> row : applicationMapper.groupByStatus(tenantId)) {
            statusCount.put(String.valueOf(row.get("status")),
                    ((Number) row.get("cnt")).longValue());
        }
        data.put("statusCount", statusCount);

        // 3. 待办任务数
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

        // 6. 最近 7 天事项趋势（1 条 SQL 代替 7 条）
        LocalDate today = LocalDate.now();
        LocalDateTime sevenDaysAgo = today.minusDays(6).atStartOfDay();
        LocalDateTime tomorrow = today.plusDays(1).atStartOfDay();
        data.put("trend", build7DayTrend(applicationMapper.groupByDate(tenantId, sevenDaysAgo, tomorrow)));

        // 7. 最近 7 天日志趋势（1 条 SQL 代替 7 条）
        data.put("logTrend", build7DayTrend(operLogMapper.groupByDate(tenantId, sevenDaysAgo, tomorrow)));

        return R.ok(data);
    }

    private List<Map<String, Object>> build7DayTrend(List<Map<String, Object>> rows) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MM-dd");
        Map<String, Long> byDay = new LinkedHashMap<>();
        for (Map<String, Object> row : rows) {
            Object day = row.get("day");
            long cnt = ((Number) row.get("cnt")).longValue();
            String key = day instanceof LocalDate
                    ? ((LocalDate) day).format(fmt)
                    : String.valueOf(day);
            byDay.put(key, cnt);
        }
        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            String key = date.format(fmt);
            Map<String, Object> item = new HashMap<>();
            item.put("date", key);
            item.put("count", byDay.getOrDefault(key, 0L));
            result.add(item);
        }
        return result;
    }
}