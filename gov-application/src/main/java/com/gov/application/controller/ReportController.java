package com.gov.application.controller;

import com.alibaba.excel.EasyExcel;
import com.gov.application.dto.ApplicationExportVO;
import com.gov.application.entity.Application;
import com.gov.application.entity.Dept;
import com.gov.application.mapper.DeptMapper;
import com.gov.application.service.ReportService;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Tag(name = "统计报表")
@RestController
@RequestMapping("/api/report")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @Autowired
    private DeptMapper deptMapper;

    @Operation(summary = "汇总统计")
    @GetMapping("/summary")
    public R<Map<String, Object>> summary(
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {
        return R.ok(reportService.summary(startTime, endTime));
    }

    @Operation(summary = "按部门统计")
    @GetMapping("/by-dept")
    public R<List<Map<String, Object>>> byDept(
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {
        return R.ok(reportService.statByDept(startTime, endTime));
    }

    @Operation(summary = "按日期统计")
    @GetMapping("/by-date")
    public R<List<Map<String, Object>>> byDate(
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {
        return R.ok(reportService.statByDate(startTime, endTime));
    }

    @Operation(summary = "导出 Excel")
    @GetMapping("/export")
    public void export(
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime,
            @RequestParam(required = false) Long deptId,
            HttpServletResponse response) throws Exception {

        List<Application> apps = reportService.detailList(startTime, endTime, deptId);

        // 部门名映射
        List<Dept> depts = deptMapper.selectList(null);
        Map<Long, String> deptMap = depts.stream()
                .collect(Collectors.toMap(
                        Dept::getId,
                        d -> d.getDeptName() == null ? "未命名部门" : d.getDeptName(),
                        (a, b) -> a));

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        List<ApplicationExportVO> list = new ArrayList<>();
        int seq = 1;
        for (Application a : apps) {
            ApplicationExportVO vo = new ApplicationExportVO();
            vo.setSeq(seq++);
            vo.setTitle(a.getTitle());
            vo.setApplicant(a.getApplicant());
            vo.setDeptName(a.getDeptId() == null ? "-" :
                    deptMap.getOrDefault(a.getDeptId(), "未知"));
            vo.setStatus(statusLabel(a.getStatus()));
            vo.setCreateTime(a.getCreateTime() == null ? "" : a.getCreateTime().format(fmt));
            list.add(vo);
        }

        // 响应头
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setCharacterEncoding("utf-8");
        String fileName = URLEncoder.encode("办件明细", StandardCharsets.UTF_8).replaceAll("\\+", "%20");
        response.setHeader("Content-Disposition",
                "attachment; filename*=UTF-8''" + fileName + ".xlsx");

        EasyExcel.write(response.getOutputStream(), ApplicationExportVO.class)
                .sheet("办件明细")
                .doWrite(list);
    }

    private String statusLabel(String status) {
        if (status == null) return "-";
        switch (status) {
            case "DRAFT": return "草稿";
            case "PENDING": return "待审批";
            case "APPROVED": return "已通过";
            default: return status;
        }
    }
}