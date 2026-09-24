package com.gov.application.service;

import com.gov.application.entity.SysMenu;

import java.util.List;

public interface SysMenuService {

    /** 菜单树（全部启用） */
    List<SysMenu> menuTree();

    /** 扁平列表（全部启用，按 parentId、orderNum 排序） */
    List<SysMenu> listAll();

    /** 详情 */
    SysMenu getById(Long id);

    /** 新增 */
    void addMenu(SysMenu menu);

    /** 修改 */
    void updateMenu(SysMenu menu);

    /** 删除（有子菜单时拒绝） */
    void deleteMenu(Long id);

    /** 某角色已分配的菜单ID */
    List<Long> menuIdsByRole(Long roleId);

    /** 当前用户的路由菜单树（只含 M/C 类型） */
    List<SysMenu> getRouters();

    /** 当前用户的按钮权限标识列表（F 类型的 perms） */
    List<String> getPermissions();
}