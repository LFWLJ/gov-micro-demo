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

/**
 * 菜单服务实现
 * <p>
 * 负责系统菜单的树形管理、动态路由生成、权限标识提取，
 * 以及基于角色的菜单授权查询。
 * </p>
 *
 * <h3>菜单类型</h3>
 * <ul>
 *     <li>{@code M} - 目录（仅作为分组，不对应具体页面）</li>
 *     <li>{@code C} - 菜单（对应前端路由和组件，必填 path 和 component）</li>
 *     <li>{@code F} - 按钮（权限粒度最小单位，必填 perms 权限标识）</li>
 * </ul>
 *
 * <h3>动态路由生成流程</h3>
 * <pre>
 * 当前用户 userId → 查询关联 roleIds → 汇总所有角色的 menuIds → 查询菜单 → 过滤 M/C 类型 → 构建树
 * </pre>
 */
@Service
public class SysMenuServiceImpl implements SysMenuService {

    @Resource
    private SysMenuMapper sysMenuMapper;

    @Resource
    private SysRoleMenuMapper sysRoleMenuMapper;

    @Resource
    private SysUserRoleMapper sysUserRoleMapper;

    /** 获取完整的菜单树（仅包含启用状态的菜单） */
    @Override
    public List<SysMenu> menuTree() {
        List<SysMenu> all = listAll();
        return buildTree(all);
    }

    /** 查询所有启用状态的菜单，按 parentId + orderNum 排序 */
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

    /**
     * 新增菜单
     * <p>
     * 根据菜单类型有不同的必填校验：
     * <ul>
     *     <li>{@code F} 按钮类型必须填写 perms（权限标识）</li>
     *     <li>{@code C} 菜单类型必须填写 path 和 component</li>
     * </ul>
     * 未传字段自动填充默认值：parentId=0, orderNum=0, visible=1, status=1。
     * </p>
     */
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

    /**
     * 更新菜单
     * <p>
     * 禁止将 parentId 指向自身；修改 perms 时需校验新值在租户内唯一。
     * </p>
     */
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

    /**
     * 删除菜单
     * <p>
     * 有子菜单时拒绝删除。删除时同步清理角色-菜单关联。
     * </p>
     */
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

    /** 查询指定角色已分配的菜单 ID */
    @Override
    public List<Long> menuIdsByRole(Long roleId) {
        return sysRoleMenuMapper.selectMenuIdsByRoleId(roleId);
    }

    /**
     * 获取当前用户的动态路由树
     * <p>
     * 只保留目录（M）和菜单（C）类型，过滤掉按钮（F）类型，
     * 供前端动态注册路由使用。
     * </p>
     */
    @Override
    public List<SysMenu> getRouters() {
        List<SysMenu> all = currentUserMenus();
        List<SysMenu> routeMenus = all.stream()
                .filter(m -> "M".equals(m.getMenuType()) || "C".equals(m.getMenuType()))
                .collect(Collectors.toList());
        return buildTree(routeMenus);
    }

    /**
     * 获取当前用户的全部权限标识
     * <p>
     * 只提取按钮（F）类型菜单的 perms 字段，去重后返回，
     * 供后端接口做细粒度权限校验使用。
     * </p>
     */
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
     * 查询当前用户被授权的全部菜单（含按钮）
     * <p>
     * 步骤：userId → roleIds → menuIds → menus。
     * 如果没有用户 ID 或没有关联角色，则返回空列表。
     * </p>
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

    /**
     * 将扁平菜单列表转换为树形结构
     * <p>
     * 使用两次遍历：第一次建立 ID → 实体映射，第二次根据 parentId 挂载子节点。
     * parentId 为 null 或 0 或找不到对应父节点的，都视为根节点。
     * </p>
     */
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