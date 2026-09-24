package com.gov.file.controller;

import com.gov.common.perm.RequiresPerm;
import com.gov.common.result.R;
import com.gov.file.dto.AttachmentSaveDTO;
import com.gov.file.service.AttachmentService;
import com.gov.file.dto.vo.AttachmentVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "附件关联")
@RestController
@RequestMapping("/api/attachment")
public class AttachmentController {

    @Autowired
    private AttachmentService attachmentService;

    @Operation(summary = "关联附件到业务对象")
    @PostMapping
    public R<Long> save(@RequestBody AttachmentSaveDTO dto,
                        @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        return R.ok("关联成功", attachmentService.save(dto, tenantId));
    }

    @Operation(summary = "查询某业务对象的所有附件")
    @GetMapping("/list")
    public R<List<AttachmentVO>> list(@RequestParam("bizType") String bizType,
                                      @RequestParam("bizId") Long bizId,
                                      @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        return R.ok(attachmentService.listByBiz(bizType, bizId, tenantId));
    }

    @Operation(summary = "删除附件关联")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable("id") Long id,
                          @RequestHeader(value = "X-Tenant-Id", required = false) String tenantId) {
        attachmentService.delete(id, tenantId);
        return R.ok("删除成功", null);
    }
}