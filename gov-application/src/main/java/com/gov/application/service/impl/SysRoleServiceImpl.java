package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.application.dto.AssignMenuDTO;
import com.gov.application.dto.AssignUserDTO;
import com.gov.application.dto.RoleQueryDTO;
import com.gov.application.entity.SysRole;
import com.gov.application.mapper.SysRoleMapper;
import com.gov.application.mapper.SysRoleMenuMapper;
import com.gov.application.mapper.SysUserRoleMapper;
import com.gov.application.service.SysRoleService;
import com.gov.common.exception.BizException;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SysRoleServiceImpl implements SysRoleService {

    @Resource
    private SysRoleMapper sysRoleMapper;

    @Resource
    private SysRoleMenuMapper sysRoleMenuMapper;

    @Resource
    private SysUserRoleMapper sysUserRoleMapper;

    @Override
    public IPage<SysRole> pageRoles(RoleQueryDTO query) {
        LambdaQueryWrapper<SysRole> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.hasText(query.getRoleName()), SysRole::getRoleName, query.getRoleName());
        qw.eq(query.getStatus() != null, SysRole::getStatus, query.getStatus());
        qw.orderByAsc(SysRole::getRoleSort);
        int pageNum = query.getPageNum() == null ? 1 : query.getPageNum();
        int pageSize = query.getPageSize() == null ? 10 : query.getPageSize();
        return sysRoleMapper.selectPage(new Page<>(pageNum, pageSize), qw);
    }

    @Override
    public void addRole(SysRole role) {
        if (!StringUtils.hasText(role.getRoleKey())) {
            throw new BizException("角色标识不能为空");
        }
        Long cnt = sysRoleMapper.selectCount(new LambdaQueryWrapper<SysRole>()
                .eq(SysRole::getRoleKey, role.getRoleKey()));
        if (cnt != null && cnt > 0) {
            throw new BizException("角色标识已存在：" + role.getRoleKey());
        }
        if (role.getStatus() == null) role.setStatus(1);
        if (role.getRoleSort() == null) role.setRoleSort(0);
        if (role.getDataScope() == null) role.setDataScope(3);
        sysRoleMapper.insert(role);
    }

    @Override
    public void updateRole(SysRole role) {
        if (role.getId() == null) throw new BizException("角色ID不能为空");
        SysRole db = sysRoleMapper.selectById(role.getId());
        if (db == null) throw new BizException("角色不存在");
        if (StringUtils.hasText(role.getRoleKey())
                && !role.getRoleKey().equals(db.getRoleKey())) {
            Long cnt = sysRoleMapper.selectCount(new LambdaQueryWrapper<SysRole>()
                    .eq(SysRole::getRoleKey, role.getRoleKey())
                    .ne(SysRole::getId, role.getId()));
            if (cnt != null && cnt > 0) {
                throw new BizException("角色标识已存在：" + role.getRoleKey());
            }
        }
        sysRoleMapper.updateById(role);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteRole(Long id) {
        if (id == null) throw new BizException("角色ID不能为空");
        List<Long> userIds = sysUserRoleMapper.selectUserIdsByRoleId(id);
        if (!CollectionUtils.isEmpty(userIds)) {
            throw new BizException("该角色下还有 " + userIds.size() + " 个用户，请先解除关联");
        }
        sysRoleMapper.deleteById(id);
        sysRoleMenuMapper.deleteByRoleId(id);
    }

    @Override
    public List<Long> getMenuIds(Long roleId) {
        return sysRoleMenuMapper.selectMenuIdsByRoleId(roleId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignMenus(Long roleId, AssignMenuDTO dto) {
        if (roleId == null) throw new BizException("角色ID不能为空");
        sysRoleMenuMapper.deleteByRoleId(roleId);
        if (dto == null || CollectionUtils.isEmpty(dto.getMenuIds())) return;
        List<Long> distinct = dto.getMenuIds().stream().distinct().collect(Collectors.toList());
        sysRoleMenuMapper.batchInsert(roleId, distinct);
    }

    @Override
    public List<Long> getUserIds(Long roleId) {
        return sysUserRoleMapper.selectUserIdsByRoleId(roleId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignUsers(Long roleId, AssignUserDTO dto) {
        if (roleId == null) throw new BizException("角色ID不能为空");
        sysUserRoleMapper.deleteByRoleId(roleId);
        if (dto == null || CollectionUtils.isEmpty(dto.getUserIds())) return;
        List<Long> distinct = dto.getUserIds().stream().distinct().collect(Collectors.toList());
        sysUserRoleMapper.batchInsert(roleId, distinct);
    }
    @Override
    public SysRole getById(Long id) {
        return sysRoleMapper.selectById(id);
    }
}