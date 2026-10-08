package com.gov.application.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.gov.application.dto.AssignMenuDTO;
import com.gov.application.dto.AssignUserDTO;
import com.gov.application.dto.RoleQueryDTO;
import com.gov.application.entity.SysRole;

import java.util.List;

public interface SysRoleService {

    IPage<SysRole> pageRoles(RoleQueryDTO query);

    SysRole getById(Long id);        // ← 就是这个，检查有没有

    /** 查询全部角色（跨租户、不分页），供下拉选择等场景使用 */
    List<SysRole> allRoles();

    void addRole(SysRole role);

    void updateRole(SysRole role);

    void deleteRole(Long id);

    List<Long> getMenuIds(Long roleId);

    void assignMenus(Long roleId, AssignMenuDTO dto);

    List<Long> getUserIds(Long roleId);

    void assignUsers(Long roleId, AssignUserDTO dto);
}