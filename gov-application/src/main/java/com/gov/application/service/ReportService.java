package com.gov.application.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.Application;
import com.gov.application.entity.Dept;
import com.gov.application.mapper.ApplicationMapper;
import com.gov.application.mapper.DeptMapper;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ReportService {

    @Autowired
    private ApplicationMapper applicationMapper;

    @Autowired
    private DeptMapper deptMapper;

    /**
     * 按部门统计
     */
    public List<Map<String, Object>> statByDept(String startTime, String endTime) {
        List<Application> apps = queryByTime(startTime, endTime);
        List<Dept> depts = deptMapper.selectList(null);
        Map<Long, String> deptMap = depts.stream()
                .collect(Collectors.toMap(
                        Dept::getId,
                        d -> d.getDeptName() == null ? "未命名部门" : d.getDeptName(),
                        (a, b) -> a));

        Map<Long, List<Application>> grouped = apps.stream()
                .filter(a -> a.getDeptId() != null)
                .collect(Collectors.groupingBy(Application::getDeptId));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<Long, List<Application>> e : grouped.entrySet()) {
            Map<String, Object> m = new HashMap<>();
            m.put("deptId", e.getKey());
            m.put("deptName", deptMap.getOrDefault(e.getKey(), "未知部门"));
            m.put("total", (long) e.getValue().size());
            m.put("approved", e.getValue().stream()
                    .filter(a -> "APPROVED".equals(a.getStatus())).count());
            m.put("pending", e.getValue().stream()
                    .filter(a -> "PENDING".equals(a.getStatus())).count());
            m.put("draft", e.getValue().stream()
                    .filter(a -> "DRAFT".equals(a.getStatus())).count());
            result.add(m);
        }
        result.sort((a, b) -> Long.compare(
                ((Number) b.get("total")).longValue(),
                ((Number) a.get("total")).longValue()));
        return result;
    }

    /**
     * 按日期统计趋势
     */
    public List<Map<String, Object>> statByDate(String startTime, String endTime) {
        List<Application> apps = queryByTime(startTime, endTime);
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        Map<String, List<Application>> grouped = apps.stream()
                .filter(a -> a.getCreateTime() != null)
                .collect(Collectors.groupingBy(
                        a -> a.getCreateTime().toLocalDate().format(fmt)));

        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<String, List<Application>> e : grouped.entrySet()) {
            Map<String, Object> m = new HashMap<>();
            m.put("date", e.getKey());
            m.put("total", (long) e.getValue().size());
        }
        result.sort(Comparator.comparing(m -> (String) m.get("date")));
        return result;
    }

    /**
     * 汇总统计
     */
    public Map<String, Object> summary(String startTime, String endTime) {
        List<Application> apps = queryByTime(startTime, endTime);
        Map<String, Object> result = new HashMap<>();
        result.put("total", apps.size());
        result.put("approved", apps.stream()
                .filter(a -> "APPROVED".equals(a.getStatus())).count());
        result.put("pending", apps.stream()
                .filter(a -> "PENDING".equals(a.getStatus())).count());
        result.put("draft", apps.stream()
                .filter(a -> "DRAFT".equals(a.getStatus())).count());
        return result;
    }

    /**
     * 查询明细（用于导出）
     */
    public List<Application> detailList(String startTime, String endTime, Long deptId) {
        LambdaQueryWrapper<Application> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(startTime)) {
            wrapper.ge(Application::getCreateTime, startTime);
        }
        if (StringUtils.hasText(endTime)) {
            wrapper.le(Application::getCreateTime, endTime + " 23:59:59");
        }
        if (deptId != null) {
            wrapper.eq(Application::getDeptId, deptId);
        }
        wrapper.orderByDesc(Application::getCreateTime);
        return applicationMapper.selectList(wrapper);
    }

    private List<Application> queryByTime(String startTime, String endTime) {
        LambdaQueryWrapper<Application> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(startTime)) {
            wrapper.ge(Application::getCreateTime, startTime);
        }
        if (StringUtils.hasText(endTime)) {
            wrapper.le(Application::getCreateTime, endTime + " 23:59:59");
        }
        return applicationMapper.selectList(wrapper);
    }
}