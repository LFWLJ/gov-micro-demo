package com.gov.application.controller;

import com.gov.application.service.NotifyService;
import com.gov.common.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 消息中心 HTTP 接口
 * <p>
 * 站内通知的只读查询 + 标已读 / 删除。
 * 所有写操作都需要传 receiver 参数，服务端会做归属校验（防越权删别人的消息）。
 * </p>
 */
@Tag(name = "消息中心")
@RestController
@RequestMapping("/api/notify")
public class NotifyController {

    @Autowired
    private NotifyService notifyService;

    @Operation(summary = "分页查询消息")
    @GetMapping("/page")
    public R<Map<String, Object>> page(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam("receiver") String receiver,
            @RequestParam(value = "isRead", required = false) Integer isRead) {
        return R.ok(notifyService.page(page, size, receiver, isRead));
    }

    @Operation(summary = "未读数量")
    @GetMapping("/unread-count")
    public R<Long> unreadCount(@RequestParam("receiver") String receiver) {
        return R.ok(notifyService.unreadCount(receiver));
    }

    @Operation(summary = "标记已读")
    @PostMapping("/read/{id}")
    public R<Void> read(@PathVariable("id") Long id,
                        @RequestParam("receiver") String receiver) {
        notifyService.read(id, receiver);
        return R.ok("已读", null);
    }

    @Operation(summary = "全部已读")
    @PostMapping("/read-all")
    public R<Void> readAll(@RequestParam("receiver") String receiver) {
        notifyService.readAll(receiver);
        return R.ok("全部已读", null);
    }

    @Operation(summary = "删除消息")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable("id") Long id,
                          @RequestParam("receiver") String receiver) {
        notifyService.delete(id, receiver);
        return R.ok("已删除", null);
    }
}