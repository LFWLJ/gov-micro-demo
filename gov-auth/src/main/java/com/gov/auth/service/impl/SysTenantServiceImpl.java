package com.gov.auth.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.auth.dto.TenantQueryDTO;
import com.gov.auth.entity.SysTenant;
import com.gov.auth.mapper.SysTenantMapper;
import com.gov.auth.service.SysTenantService;
import com.gov.common.exception.BizException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class SysTenantServiceImpl implements SysTenantService {

    @Autowired
    private SysTenantMapper sysTenantMapper;

    @Override
    public IPage<SysTenant> pageTenants(TenantQueryDTO query) {
        LambdaQueryWrapper<SysTenant> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.hasText(query.getTenantName()), SysTenant::getTenantName, query.getTenantName());
        qw.eq(query.getStatus() != null, SysTenant::getStatus, query.getStatus());
        qw.orderByAsc(SysTenant::getId);
        int pageNum = query.getPageNum() == null ? 1 : query.getPageNum();
        int pageSize = query.getPageSize() == null ? 10 : query.getPageSize();
        return sysTenantMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    @Override
    public SysTenant getById(Long id) {
        return sysTenantMapper.selectById(id);
    }

    @Override
    public void addTenant(SysTenant tenant) {
        if (!StringUtils.hasText(tenant.getTenantId())) {
            throw new BizException("租户标识不能为空");
        }
        if (!StringUtils.hasText(tenant.getTenantName())) {
            throw new BizException("租户名称不能为空");
        }
        Long cnt = sysTenantMapper.selectCount(
                new LambdaQueryWrapper<SysTenant>()
                        .eq(SysTenant::getTenantId, tenant.getTenantId()));
        if (cnt != null && cnt > 0) {
            throw new BizException("租户标识已存在：" + tenant.getTenantId());
        }
        if (tenant.getStatus() == null) tenant.setStatus(1);
        sysTenantMapper.insert(tenant);
    }

    @Override
    public void updateTenant(SysTenant tenant) {
        if (tenant.getId() == null) throw new BizException("租户ID不能为空");
        SysTenant db = sysTenantMapper.selectById(tenant.getId());
        if (db == null) throw new BizException("租户不存在");
        // tenant_id 不可改（改了会破坏已有数据关联）
        tenant.setTenantId(null);
        sysTenantMapper.updateById(tenant);
    }

    @Override
    public void deleteTenant(Long id) {
        if (id == null) throw new BizException("租户ID不能为空");
        SysTenant db = sysTenantMapper.selectById(id);
        if (db == null) throw new BizException("租户不存在");
        if ("tenant_a".equals(db.getTenantId())) {
            throw new BizException("默认租户不允许删除");
        }
        sysTenantMapper.deleteById(id);
    }
}