package com.gov.auth.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.gov.auth.dto.TenantQueryDTO;
import com.gov.auth.entity.SysTenant;

public interface SysTenantService {

    IPage<SysTenant> pageTenants(TenantQueryDTO query);

    SysTenant getById(Long id);

    void addTenant(SysTenant tenant);

    void updateTenant(SysTenant tenant);

    void deleteTenant(Long id);
}