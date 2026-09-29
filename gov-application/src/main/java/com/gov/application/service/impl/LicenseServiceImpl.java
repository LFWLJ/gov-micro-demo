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
import org.springframework.beans.factory.annotation.Value;
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
import java.util.concurrent.ThreadLocalRandom;

@Service
public class LicenseServiceImpl implements LicenseService {

    @Autowired
    private LicenseMapper licenseMapper;

    @Autowired
    private LicenseTemplateMapper templateMapper;

    /** 公开验真页地址，可通过 gov.license.verify-url 覆盖（原来硬编码在方法里） */
    @Value("${gov.license.verify-url:http://localhost:5173/verify}")
    private String verifyUrlPrefix;

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

        // ★ 证照号用 ThreadLocalRandom 取 4 位（原为 Math.random()*1000，同秒内碰撞概率偏高；
        //   license_no 上有唯一索引兜底，碰撞会直接报错而不是静默重复）
        String licenseNo = "LIC-" + LocalDateTime.now().format(
                DateTimeFormatter.ofPattern("yyyyMMddHHmmss"))
                + "-" + ThreadLocalRandom.current().nextInt(1000, 10000);
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

        // ★ 不再在事务内生成 PDF：原实现把 pdfBytes 生成后**直接丢弃**，
        //   既白占了事务时间（每次都要加载约 10MB 字体），又让 fileUrl 指向不存在的接口。
        //   PDF 改为下载时按需渲染（renderPdf + GET /api/license/download/{id}）。
        license.setFileUrl("/api/license/download/" + license.getId());
        licenseMapper.updateById(license);

        Map<String, Object> result = new HashMap<>();
        result.put("id", license.getId());
        result.put("licenseNo", licenseNo);
        result.put("verifyCode", verifyCode);
        result.put("fileUrl", license.getFileUrl());
        return result;
    }

    @Override
    public Map<String, Object> verify(String verifyCode) {
        // ★ 公开验真：验真码全局唯一，此处必须跨租户查询
        //   （白名单接口无租户上下文，套用租户条件会永远查不到）
        License license = licenseMapper.selectByVerifyCodeAcrossTenant(verifyCode);
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
    public byte[] renderPdf(Long id) {
        License license = licenseMapper.selectById(id);
        if (license == null) {
            throw new BizException("证照不存在");
        }
        LicenseTemplate template = templateMapper.selectOne(
                new LambdaQueryWrapper<LicenseTemplate>()
                        .eq(LicenseTemplate::getTemplateCode, license.getTemplateCode()));
        String templateName = (template == null) ? "电子证照" : template.getTemplateName();
        String verifyUrl = verifyUrlPrefix + "?code=" + license.getVerifyCode();
        try {
            return LicensePdfUtil.generate(
                    license.getLicenseNo(),
                    templateName,
                    license.getHolderName(),
                    license.getHolderIdCard(),
                    license.getIssueDept(),
                    license.getIssueDate(),
                    license.getExpireDate(),
                    license.getContentJson(),
                    verifyUrl
            );
        } catch (Exception e) {
            throw new BizException("生成证照 PDF 失败: " + e.getMessage());
        }
    }

    @Override
    public void revoke(Long id) {
        License license = licenseMapper.selectById(id);
        if (license == null) throw new BizException("证照不存在");
        license.setStatus("REVOKED");
        licenseMapper.updateById(license);
    }
}