package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.SysMenu;
import com.gov.application.mapper.SysMenuMapper;
import com.gov.application.mapper.SysRoleMenuMapper;
import com.gov.application.mapper.SysUserRoleMapper;
import com.gov.application.service.SysMenuService;
import com.gov.application.tenant.DataScopeContext;
import com.gov.common.exception.BizException;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class SysMenuServiceImpl implements SysMenuService {

    @Resource
    private SysMenuMapper sysMenuMapper;

    @Resource
    private SysRoleMenuMapper sysRoleMenuMapper;

    @Resource
    private SysUserRoleMapper sysUserRoleMapper;

    // ==================== 原有方法 ====================

    @Override
    public List<SysMenu> menuTree() {
        List<SysMenu> all = listAll();
        return buildTree(all);
    }

    @Override
    public List<SysMenu> listAll() {
        return sysMenuMapper.selectList(
                new LambdaQueryWrapper<SysMenu>()
                        .eq(SysMenu::getStatus, 1)
                        .orderByAsc(SysMenu::getParentId)
                        .orderByAsc(SysMenu::getOrderNum));
    }

    @Override
    public SysMenu getById(Long id) {
        return sysMenuMapper.selectById(id);
    }

    @Override
    public void addMenu(SysMenu menu) {
        if (!StringUtils.hasText(menu.getMenuName())) throw new BizException("菜单名称不能为空");
        if (!StringUtils.hasText(menu.getMenuType())) throw new BizException("菜单类型不能为空");
        if ("F".equals(menu.getMenuType()) && !StringUtils.hasText(menu.getPerms())) {
            throw new BizException("按钮类型必须填写权限标识");
        }
        if ("C".equals(menu.getMenuType())) {
            if (!StringUtils.hasText(menu.getPath())) throw new BizException("菜单类型必须填写路由地址");
            if (!StringUtils.hasText(menu.getComponent())) throw new BizException("菜单类型必须填写组件名");
        }
        if (menu.getParentId() == null) menu.setParentId(0L);
        if (menu.getOrderNum() == null) menu.setOrderNum(0);
        if (menu.getVisible() == null) menu.setVisible(1);
        if (menu.getStatus() == null) menu.setStatus(1);
        sysMenuMapper.insert(menu);
    }

    @Override
    public void updateMenu(SysMenu menu) {
        if (menu.getId() == null) throw new BizException("菜单ID不能为空");
        SysMenu db = sysMenuMapper.selectById(menu.getId());
        if (db == null) throw new BizException("菜单不存在");
        if (menu.getParentId() != null && menu.getParentId().equals(menu.getId())) {
            throw new BizException("上级菜单不能是自己");
        }
        if (StringUtils.hasText(menu.getPerms()) && !menu.getPerms().equals(db.getPerms())) {
            Long cnt = sysMenuMapper.selectCount(
                    new LambdaQueryWrapper<SysMenu>()
                            .eq(SysMenu::getPerms, menu.getPerms())
                            .ne(SysMenu::getId, menu.getId()));
            if (cnt != null && cnt > 0) {
                throw new BizException("权限标识已存在：" + menu.getPerms());
            }
        }
        sysMenuMapper.updateById(menu);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteMenu(Long id) {
        if (id == null) throw new BizException("菜单ID不能为空");
        SysMenu db = sysMenuMapper.selectById(id);
        if (db == null) throw new BizException("菜单不存在");
        Long childCount = sysMenuMapper.selectCount(
                new LambdaQueryWrapper<SysMenu>().eq(SysMenu::getParentId, id));
        if (childCount != null && childCount > 0) {
            throw new BizException("该菜单下还有 " + childCount + " 个子菜单，请先删除子菜单");
        }
        sysMenuMapper.deleteById(id);
        sysRoleMenuMapper.deleteByMenuId(id);
    }

    @Override
    public List<Long> menuIdsByRole(Long roleId) {
        return sysRoleMenuMapper.selectMenuIdsByRoleId(roleId);
    }

    // ==================== 新增：动态路由 ====================

    @Override
    public List<SysMenu> getRouters() {
        List<SysMenu> all = currentUserMenus();
        // 路由树只保留 M（目录）和 C（菜单）
        List<SysMenu> routeMenus = all.stream()
                .filter(m -> "M".equals(m.getMenuType()) || "C".equals(m.getMenuType()))
                .collect(Collectors.toList());
        return buildTree(routeMenus);
    }

    @Override
    public List<String> getPermissions() {
        return currentUserMenus().stream()
                .filter(m -> "F".equals(m.getMenuType()))
                .map(SysMenu::getPerms)
                .filter(StringUtils::hasText)
                .distinct()
                .collect(Collectors.toList());
    }

    /**
     * 当前用户被授权的全部菜单（含按钮）
     * 步骤：userId → roleIds → menuIds → menus
     */
    private List<SysMenu> currentUserMenus() {
        String userIdStr = DataScopeContext.getUserId();
        if (!StringUtils.hasText(userIdStr)) {
            return new ArrayList<>();
        }
        Long userId;
        try {
            userId = Long.parseLong(userIdStr);
        } catch (NumberFormatException e) {
            return new ArrayList<>();
        }

        List<Long> roleIds = sysUserRoleMapper.selectRoleIdsByUserId(userId);
        if (CollectionUtils.isEmpty(roleIds)) {
            return new ArrayList<>();
        }

        // 汇总所有角色的菜单 ID
        Set<Long> menuIdSet = roleIds.stream()
                .flatMap(rid -> sysRoleMenuMapper.selectMenuIdsByRoleId(rid).stream())
                .collect(Collectors.toSet());
        if (menuIdSet.isEmpty()) {
            return new ArrayList<>();
        }

        return sysMenuMapper.selectList(
                new LambdaQueryWrapper<SysMenu>()
                        .in(SysMenu::getId, menuIdSet)
                        .eq(SysMenu::getStatus, 1)
                        .orderByAsc(SysMenu::getParentId)
                        .orderByAsc(SysMenu::getOrderNum));
    }

    /** 扁平列表转树 */
    private List<SysMenu> buildTree(List<SysMenu> all) {
        Map<Long, SysMenu> map = new HashMap<>();
        for (SysMenu m : all) {
            m.setChildren(new ArrayList<>());
            map.put(m.getId(), m);
        }
        List<SysMenu> roots = new ArrayList<>();
        for (SysMenu m : all) {
            Long pid = m.getParentId();
            if (pid == null || pid == 0L || !map.containsKey(pid)) {
                roots.add(m);
            } else {
                map.get(pid).getChildren().add(m);
            }
        }
        return roots;
    }
}