package com.gov.application.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.License;
import com.gov.application.entity.LicenseTemplate;
import com.gov.application.mapper.LicenseMapper;
import com.gov.application.mapper.LicenseTemplateMapper;
import com.gov.application.util.LicensePdfUtil;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import com.gov.file.service.FileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class LicenseService {

    @Autowired
    private LicenseMapper licenseMapper;

    @Autowired
    private LicenseTemplateMapper templateMapper;

    /**
     * 分页查询证照
     */
    public Map<String, Object> page(int page, int size, String keyword, String status) {
        LambdaQueryWrapper<License> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(License::getLicenseNo, keyword)
                    .or().like(License::getHolderName, keyword));
        }
        if (StringUtils.hasText(status)) {
            wrapper.eq(License::getStatus, status);
        }
        wrapper.orderByDesc(License::getId);

        Page<License> p = new Page<>(page, size);
        Page<License> result = licenseMapper.selectPage(p, wrapper);

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return data;
    }

    /**
     * 查询模板列表
     */
    public List<LicenseTemplate> templates() {
        return templateMapper.selectList(
                new LambdaQueryWrapper<LicenseTemplate>()
                        .eq(LicenseTemplate::getStatus, 1));
    }

    /**
     * 生成证照
     */
    @Transactional
    public Map<String, Object> issue(License license) {
        String tenantId = TenantContext.get();
        if (tenantId == null) throw new BizException("缺少租户标识");

        // 生成证照编号
        String licenseNo = "LIC-" + LocalDateTime.now().format(
                DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + "-" + (int)(Math.random() * 1000);
        license.setLicenseNo(licenseNo);
        license.setTenantId(tenantId);
        license.setStatus("VALID");
        license.setCreateTime(LocalDateTime.now());

        // 生成验真码
        String verifyCode = UUID.randomUUID().toString().replace("-", "").substring(0, 16);
        license.setVerifyCode(verifyCode);

        // 查模板
        LicenseTemplate template = templateMapper.selectOne(
                new LambdaQueryWrapper<LicenseTemplate>()
                        .eq(LicenseTemplate::getTemplateCode, license.getTemplateCode()));
        if (template == null) throw new BizException("证照模板不存在");

        // 先入库拿到 ID
        licenseMapper.insert(license);

        // 生成 PDF
        try {
            String verifyUrl = "http://localhost:5173/verify?code=" + verifyCode;
            byte[] pdfBytes = LicensePdfUtil.generate(
                    licenseNo,
                    template.getTemplateName(),
                    license.getHolderName(),
                    license.getHolderIdCard(),
                    license.getIssueDept(),
                    license.getIssueDate(),
                    license.getExpireDate(),
                    license.getContentJson(),
                    verifyUrl
            );

            // 上传到 MinIO
            // 这里简化处理，直接存到本地或返回 byte[]，实际项目通过 Feign 调 gov-file 上传
            // 下面用模拟 URL
            String fileUrl = "/api/license/download/" + license.getId();
            license.setFileUrl(fileUrl);
            licenseMapper.updateById(license);

        } catch (Exception e) {
            throw new BizException("生成证照失败: " + e.getMessage());
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", license.getId());
        result.put("licenseNo", licenseNo);
        result.put("verifyCode", verifyCode);
        result.put("fileUrl", license.getFileUrl());
        return result;
    }

    /**
     * 验真
     */
    public Map<String, Object> verify(String verifyCode) {
        License license = licenseMapper.selectOne(
                new LambdaQueryWrapper<License>()
                        .eq(License::getVerifyCode, verifyCode));
        if (license == null) {
            throw new BizException("证照不存在");
        }

        Map<String, Object> result = new HashMap<>();
        result.put("licenseNo", license.getLicenseNo());
        result.put("holderName", license.getHolderName());
        result.put("issueDept", license.getIssueDept());
        result.put("issueDate", license.getIssueDate());
        result.put("expireDate", license.getExpireDate());
        result.put("status", license.getStatus());

        // 检查是否过期
        if (license.getExpireDate() != null &&
                license.getExpireDate().isBefore(LocalDate.now())) {
            result.put("expired", true);
        } else {
            result.put("expired", false);
        }
        return result;
    }

    /**
     * 吊销证照
     */
    public void revoke(Long id) {
        License license = licenseMapper.selectById(id);
        if (license == null) throw new BizException("证照不存在");
        license.setStatus("REVOKED");
        licenseMapper.updateById(license);
    }
}