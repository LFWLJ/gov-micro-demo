package com.gov.application.controller;

import com.gov.application.entity.Appointment;
import com.gov.application.service.AppointmentService;
import com.gov.common.log.OpLog;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "预约取号")
@RestController
@RequestMapping("/api/appointment")
public class AppointmentController {

    @Autowired
    private AppointmentService appointmentService;

    @Operation(summary = "分页查询")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "appointDate", required = false) String appointDate) {
        return R.ok(appointmentService.page(page, size, keyword, status, appointDate));
    }

    @Operation(summary = "创建预约")
    @PostMapping
    @OpLog(module = "预约取号", operation = "创建预约")
    public R<Map<String, Object>> create(@RequestBody Appointment appointment) {
        return R.ok("预约成功", appointmentService.create(appointment));
    }

    @Operation(summary = "签到")
    @PostMapping("/checkin/{id}")
    @OpLog(module = "预约取号", operation = "签到")
    public R<Void> checkin(@PathVariable("id") Long id) {
        appointmentService.checkin(id);
        return R.ok("签到成功", null);
    }

    @Operation(summary = "办结")
    @PostMapping("/finish/{id}")
    @OpLog(module = "预约取号", operation = "办结")
    public R<Void> finish(@PathVariable("id") Long id) {
        appointmentService.finish(id);
        return R.ok("已办结", null);
    }

    @Operation(summary = "取消预约")
    @PostMapping("/cancel/{id}")
    @OpLog(module = "预约取号", operation = "取消预约")
    public R<Void> cancel(@PathVariable("id") Long id,
                          @RequestBody(required = false) Map<String, String> body) {
        appointmentService.cancel(id, body == null ? null : body.get("reason"));
        return R.ok("已取消", null);
    }

    @Operation(summary = "今日排队列表")
    @GetMapping("/queue")
    public R<List<Appointment>> queue() {
        return R.ok(appointmentService.todayQueue());
    }

    @Operation(summary = "今日统计")
    @GetMapping("/stats")
    public R<Map<String, Object>> stats() {
        return R.ok(appointmentService.stats());
    }
}