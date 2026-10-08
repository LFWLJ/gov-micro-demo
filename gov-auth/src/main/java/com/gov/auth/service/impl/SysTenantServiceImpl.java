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

/**
 * 租户管理业务实现
 * <p>
 * 负责租户（多租户系统中的顶层隔离单元）的全生命周期管理：
 * <ul>
 *     <li>新增时做 tenantId 唯一校验，tenantId 作为整个多租户体系的隔离键，一经创建不可修改。</li>
 *     <li>更新时强制把 tenantId 置空，防止调用方误改导致已存在的业务数据失联。</li>
 *     <li>删除时保护默认租户 {@code tenant_a}（系统初始化自带，禁止删除）。</li>
 * </ul>
 * 注意：SysTenant 本身是租户元数据表，因此 MyBatis-Plus 租户插件不会对它拼 tenant_id 条件
 * （见 {@code TenantLineHandlerImpl#ignoreTable}），读操作是全租户可见的，这也是我们能用
 * tenantId 做唯一性校验的前提。
 * </p>
 */
@Service
public class SysTenantServiceImpl implements SysTenantService {

    @Autowired
    private SysTenantMapper sysTenantMapper;

    /**
     * 分页查询租户列表，支持按租户名称模糊搜 + 状态过滤
     */
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

    /**
     * 按主键查询单个租户
     */
    @Override
    public SysTenant getById(Long id) {
        return sysTenantMapper.selectById(id);
    }

    /**
     * 新增租户
     * <p>
     * tenantId 和 tenantName 必填，tenantId 全局唯一。
     * 新建租户默认启用状态（status = 1）。
     * </p>
     */
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

    /**
     * 更新租户信息
     * <p>
     * tenantId 字段在这里被强制置空，原因：tenantId 是跨表关联键
     * （用户、角色、业务数据都靠它隔离），一旦修改将导致历史数据全部失联。
     * </p>
     */
    @Override
    public void updateTenant(SysTenant tenant) {
        if (tenant.getId() == null) throw new BizException("租户ID不能为空");
        SysTenant db = sysTenantMapper.selectById(tenant.getId());
        if (db == null) throw new BizException("租户不存在");
        tenant.setTenantId(null);
        sysTenantMapper.updateById(tenant);
    }

    /**
     * 删除租户
     * <p>
     * 默认租户 {@code tenant_a} 作为系统初始化数据禁止删除，
     * 否则会导致全局用户、业务数据失去租户归属。
     * </p>
     */
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