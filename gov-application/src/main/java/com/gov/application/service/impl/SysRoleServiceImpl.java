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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 角色服务实现
 * <p>
 * 提供角色 CRUD、角色-菜单分配、角色-用户分配等功能。
 * 所有操作自动受 MyBatis-Plus 租户拦截器保护（sys_role、sys_role_menu、sys_user_role 均已纳入）。
 * </p>
 *
 * <h3>核心约束</h3>
 * <ul>
 *     <li>角色标识 roleKey 在全租户内唯一，创建和更新时都会校验</li>
 *     <li>删除角色前必须先解除所有用户关联，否则拒绝删除</li>
 *     <li>角色-菜单、角色-用户的分配采用"先删后插"策略，并在事务中执行</li>
 * </ul>
 */
@Service
public class SysRoleServiceImpl implements SysRoleService {

    private static final Logger log = LoggerFactory.getLogger(SysRoleServiceImpl.class);

    @Resource
    private SysRoleMapper sysRoleMapper;

    @Resource
    private SysRoleMenuMapper sysRoleMenuMapper;

    @Resource
    private SysUserRoleMapper sysUserRoleMapper;

    /**
     * 分页查询角色列表
     * <p>
     * 支持按角色名称模糊搜索、按状态筛选，按角色排序号升序排列。
     * </p>
     */
    @Override
    public IPage<SysRole> pageRoles(RoleQueryDTO query) {
        LambdaQueryWrapper<SysRole> qw = new LambdaQueryWrapper<>();
        qw.like(StringUtils.hasText(query.getRoleName()), SysRole::getRoleName, query.getRoleName());
        qw.eq(query.getStatus() != null, SysRole::getStatus, query.getStatus());
        qw.orderByAsc(SysRole::getRoleSort);
        int pageNum = query.getPageNum() == null ? 1 : query.getPageNum();
        int pageSize = query.getPageSize() == null ? 10 : query.getPageSize();
        // 列表跨租户展示（selectPageAcrossTenant 内部显式豁免租户条件）；
        // 写操作仍受租户拦截器保护，详见 SysRoleMapper 的注释。
        return sysRoleMapper.selectPageAcrossTenant(new Page<>(pageNum, pageSize), qw);
    }

    /**
     * 查询全部角色（跨租户、不分页）
     */
    @Override
    public List<SysRole> allRoles() {
        return sysRoleMapper.selectListAcrossTenant(
                new LambdaQueryWrapper<SysRole>().orderByAsc(SysRole::getRoleSort));
    }

    /**
     * 新增角色
     * <p>
     * roleKey 必填且在租户内唯一；未传字段自动填充默认值（status=1, sort=0, dataScope=3）。
     * 创建后**自动分配默认菜单**，避免"建完角色却是空菜单、该角色用户登录后看不到任何页面"：
     * <ul>
     *     <li>roleKey = ROLE_ADMIN → 全部菜单（含按钮权限，即完整管理员）</li>
     *     <li>其它角色 → 仅目录/菜单节点，**不预置按钮权限**（可由管理员在界面上按需勾选，
     *         避免"新建一个角色就默认拥有证照吊销/删除用户"这类危险操作）</li>
     * </ul>
     * </p>
     */
    @Override
    @Transactional
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

        // 默认菜单分配（与角色创建同事务，失败一起回滚）
        boolean isAdmin = "ROLE_ADMIN".equalsIgnoreCase(role.getRoleKey());
        List<Long> defaultMenuIds = isAdmin
                ? sysRoleMenuMapper.selectAllMenuIds()
                : sysRoleMenuMapper.selectNavigableMenuIds();
        if (defaultMenuIds != null && !defaultMenuIds.isEmpty()) {
            sysRoleMenuMapper.batchInsert(role.getId(), defaultMenuIds);
        }
        log.info("新建角色默认分配菜单: roleKey={}, roleId={}, isAdmin={}, menuCount={}",
                role.getRoleKey(), role.getId(), isAdmin,
                defaultMenuIds == null ? 0 : defaultMenuIds.size());
    }

    /**
     * 更新角色信息
     * <p>
     * 如果修改了 roleKey，需校验新值在租户内唯一（排除自身）。
     * </p>
     */
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

    /**
     * 删除角色
     * <p>
     * 先检查是否还有用户绑定该角色，有则拒绝删除。删除时同步清理角色-菜单关联。
     * </p>
     */
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

    /** 查询角色已分配的菜单 ID 列表 */
    @Override
    public List<Long> getMenuIds(Long roleId) {
        return sysRoleMenuMapper.selectMenuIdsByRoleId(roleId);
    }

    /**
     * 为角色分配菜单（覆盖式）
     * <p>
     * 先删除该角色的所有菜单关联，再批量插入新关联。菜单 ID 会去重。
     * 在事务中执行，确保数据一致性。
     * </p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void assignMenus(Long roleId, AssignMenuDTO dto) {
        if (roleId == null) throw new BizException("角色ID不能为空");
        sysRoleMenuMapper.deleteByRoleId(roleId);
        if (dto == null || CollectionUtils.isEmpty(dto.getMenuIds())) return;
        List<Long> distinct = dto.getMenuIds().stream().distinct().collect(Collectors.toList());
        sysRoleMenuMapper.batchInsert(roleId, distinct);
    }

    /** 查询角色已分配的用户 ID 列表 */
    @Override
    public List<Long> getUserIds(Long roleId) {
        return sysUserRoleMapper.selectUserIdsByRoleId(roleId);
    }

    /**
     * 为角色分配用户（覆盖式）
     * <p>
     * 先删除该角色的所有用户关联，再批量插入新关联。用户 ID 会去重。
     * </p>
     */
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