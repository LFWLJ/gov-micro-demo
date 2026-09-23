package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.entity.License;
import com.gov.application.entity.LicenseTemplate;
import com.gov.application.mapper.LicenseMapper;
import com.gov.application.mapper.LicenseTemplateMapper;
import com.gov.application.service.LicenseService;
import com.gov.application.util.LicensePdfUtil;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class LicenseServiceImpl implements LicenseService {

    @Autowired
    private LicenseMapper licenseMapper;

    @Autowired
    private LicenseTemplateMapper templateMapper;

    @Override
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

    @Override
    public List<LicenseTemplate> templates() {
        return templateMapper.selectList(
                new LambdaQueryWrapper<LicenseTemplate>()
                        .eq(LicenseTemplate::getStatus, 1));
    }

    @Override
    @Transactional
    public Map<String, Object> issue(License license) {
        String tenantId = TenantContext.get();
        if (tenantId == null) throw new BizException("缺少租户标识");

        String licenseNo = "LIC-" + LocalDateTime.now().format(
                DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + "-" + (int)(Math.random() * 1000);
        license.setLicenseNo(licenseNo);
        license.setTenantId(tenantId);
        license.setStatus("VALID");
        license.setCreateTime(LocalDateTime.now());

        String verifyCode = UUID.randomUUID().toString().replace("-", "").substring(0, 16);
        license.setVerifyCode(verifyCode);

        LicenseTemplate template = templateMapper.selectOne(
                new LambdaQueryWrapper<LicenseTemplate>()
                        .eq(LicenseTemplate::getTemplateCode, license.getTemplateCode()));
        if (template == null) throw new BizException("证照模板不存在");

        licenseMapper.insert(license);

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

    @Override
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

        if (license.getExpireDate() != null &&
                license.getExpireDate().isBefore(LocalDate.now())) {
            result.put("expired", true);
        } else {
            result.put("expired", false);
        }
        return result;
    }

    @Override
    public void revoke(Long id) {
        License license = licenseMapper.selectById(id);
        if (license == null) throw new BizException("证照不存在");
        license.setStatus("REVOKED");
        licenseMapper.updateById(license);
    }
}