package com.gov.auth.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.auth.dto.UserSaveDTO;
import com.gov.auth.entity.SysUser;
import com.gov.auth.mapper.SysUserMapper;
import com.gov.auth.service.UserService;
import com.gov.common.exception.BizException;
import com.gov.common.redis.RedisKeys;
import com.gov.common.redis.RedisService;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

/**
 * 用户服务实现
 * <p>
 * 负责用户的登录认证、CRUD、密码管理等核心业务。
 *
 * <h3>多租户隔离</h3>
 * {@code sys_user} 表被排除在 MyBatis-Plus 租户拦截器之外（因为登录时需要跨租户按用户名查询），
 * 因此本类中所有涉及租户隔离的操作都必须显式处理：
 * <ul>
 *     <li>{@link #page(int, int, String)} 显式追加 tenant_id 条件</li>
 *     <li>{@link #assertSameTenant(SysUser)} 在按 ID 读写改删前校验归属</li>
 * </ul>
 * </p>
 *
 * <h3>安全设计要点</h3>
 * <ul>
 *     <li>密码统一使用 BCrypt 加密（见 {@link SecurityConfig}），不允许明文存储或比对</li>
 *     <li>敏感操作（改密、重置、删除）后清除 Redis 缓存中的用户信息</li>
 *     <li>按 ID 查询失败时统一返回"用户不存在"，不暴露其他租户用户是否存在</li>
 * </ul>
 */
@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private RedisService redisService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * 按用户名查询用户（登录专用，跨租户）
     * <p>
     * 不做 Redis 缓存：登录是低频操作，直查数据库即可；
     * 同时避免 bcrypt 哈希值被缓存外泄，以及缓存键的跨租户歧义。
     * </p>
     */
    @Override
    public SysUser findByUsername(String username) {
        return sysUserMapper.selectOne(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getUsername, username));
    }

    /**
     * 按 ID 查询用户，同时校验归属当前租户
     */
    @Override
    public SysUser findById(Long id) {
        SysUser user = sysUserMapper.selectById(id);
        if (user != null) {
            assertSameTenant(user);
        }
        return user;
    }

    /**
     * 用户登录认证
     * <p>
     * 使用 BCrypt 校验密码，仅对启用状态（status=1）的用户放行。
     * </p>
     *
     * @return 认证通过返回用户实体，否则返回 null
     */
    @Override
    public SysUser login(String username, String password) {
        SysUser user = findByUsername(username);
        if (user == null) return null;
        if (user.getStatus() == null || user.getStatus() != 1) return null;

        if (passwordEncoder.matches(password, user.getPassword())) {
            return user;
        }

        return null;
    }

    /**
     * 分页查询当前租户下的用户列表
     * <p>
     * 显式追加 tenant_id 条件（因为 sys_user 不在租户拦截器覆盖范围内），
     * 查询结果会清除 password 字段、补充部门名称与状态标签。
     * </p>
     */
    @Override
    public Map<String, Object> page(int page, int size, String keyword) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        // 列表按需求跨租户展示全部用户。
        // 只放开了"看得见"：按 ID 的查询/修改/删除/重置密码仍经 assertSameTenant 校验归属，
        // 因此不会重现跨租户改密/删用户那条链（sys_user 因登录需要不在租户拦截器内，必须靠这里兜）。
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(SysUser::getUsername, keyword)
                    .or().like(SysUser::getRealName, keyword));
        }
        wrapper.orderByDesc(SysUser::getId);

        Page<SysUser> p = new Page<>(page, size);
        Page<SysUser> result = sysUserMapper.selectPage(p, wrapper);

        result.getRecords().forEach(u -> u.setPassword(null));
        fillDeptNames(result.getRecords());
        fillStatusLabels(result.getRecords());

        Map<String, Object> data = new HashMap<>();
        data.put("total", result.getTotal());
        data.put("records", result.getRecords());
        return data;
    }

    @Override
    public List<SysUser> allUsers() {
        // 跨租户返回全部用户，且不分页。
        // 与 page() 一致的脱敏与展示处理：密码置空、补部门名、补状态文案。
        // 供「角色分配用户」「下拉选择」等需要完整集合的场景使用，
        // 避免前端用 page(size=999) 硬凑（分页插件 maxLimit=500 会把 999 截成 500）。
        List<SysUser> users = sysUserMapper.selectList(
                new LambdaQueryWrapper<SysUser>().orderByDesc(SysUser::getId));
        users.forEach(u -> u.setPassword(null));
        fillDeptNames(users);
        fillStatusLabels(users);
        return users;
    }

    /** 获取当前租户，缺失直接失败 —— 绝不允许退化成"不过滤" */
    private String requireTenant() {
        String tenantId = TenantContext.get();
        if (!StringUtils.hasText(tenantId)) {
            throw new BizException("缺少租户标识");
        }
        return tenantId;
    }

    /**
     * 校验目标用户属于当前租户。
     * sys_user 未纳入 MyBatis-Plus 租户拦截器，所有按 id 的读/改/删都必须显式校验，
     * 否则可跨租户查看、改密（账号接管）与删除用户。
     */
    private void assertSameTenant(SysUser user) {
        if (!requireTenant().equals(user.getTenantId())) {
            // 不区分"不存在"与"不属于本租户"，避免暴露其他租户用户是否存在
            throw new BizException("用户不存在");
        }
    }

    /** 批量填充用户的部门名称 */
    private void fillDeptNames(List<SysUser> users) {
        Set<Long> deptIds = users.stream()
                .map(SysUser::getDeptId)
                .filter(id -> id != null)
                .collect(Collectors.toSet());
        if (deptIds.isEmpty()) return;

        String placeholders = deptIds.stream().map(id -> "?")
                .collect(Collectors.joining(","));
        String sql = "SELECT id, dept_name FROM sys_dept WHERE id IN (" + placeholders + ")";
        Map<Long, String> deptMap = new HashMap<>();
        jdbcTemplate.query(sql, deptIds.toArray(), (rs) -> {
            deptMap.put(rs.getLong("id"), rs.getString("dept_name"));
        });
        for (SysUser u : users) {
            if (u.getDeptId() != null) {
                u.setDeptName(deptMap.get(u.getDeptId()));
            }
        }
    }

    /** 将 status 数值转为可读标签 */
    private void fillStatusLabels(List<SysUser> users) {
        for (SysUser u : users) {
            if (u.getStatus() == null) continue;
            u.setStatusLabel(u.getStatus() == 1 ? "启用" : "禁用");
        }
    }

    /**
     * 创建新用户
     * <p>
     * 用户名全局唯一（跨租户），租户 ID 从当前上下文获取，
     * 密码使用 BCrypt 加密存储。
     * </p>
     */
    @Override
    public Long create(UserSaveDTO dto) {
        if (!StringUtils.hasText(dto.getUsername())) {
            throw new BizException("用户名不能为空");
        }
        if (!StringUtils.hasText(dto.getPassword())) {
            throw new BizException("密码不能为空");
        }
        Long count = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getUsername, dto.getUsername()));
        if (count > 0) {
            throw new BizException("用户名已存在");
        }

        String tenantId = TenantContext.get();
        if (!StringUtils.hasText(tenantId)) {
            throw new BizException("缺少租户标识");
        }

        SysUser user = new SysUser();
        user.setUsername(dto.getUsername());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRealName(dto.getRealName());
        user.setTenantId(tenantId);
        user.setRoles(dto.getRoles() == null ? "ROLE_USER" : dto.getRoles());
        user.setDeptId(dto.getDeptId());
        user.setDataScope(dto.getDataScope() == null ? 3 : dto.getDataScope());
        user.setStatus(dto.getStatus() == null ? 1 : dto.getStatus());

        sysUserMapper.insert(user);
        return user.getId();
    }

    /** 更新用户信息（不含密码），同步清除 Redis 缓存 */
    @Override
    public void update(UserSaveDTO dto) {
        if (dto.getId() == null) {
            throw new BizException("用户ID不能为空");
        }
        SysUser user = sysUserMapper.selectById(dto.getId());
        if (user == null) {
            throw new BizException("用户不存在");
        }
        assertSameTenant(user);
        user.setRealName(dto.getRealName());
        user.setRoles(dto.getRoles());
        user.setDeptId(dto.getDeptId());
        user.setDataScope(dto.getDataScope());
        user.setStatus(dto.getStatus());
        sysUserMapper.updateById(user);

        redisService.delete(RedisKeys.userCache(user.getUsername()));
    }

    /** 用户自助修改个人资料（仅 realName） */
    @Override
    public void updateProfile(Long userId, String realName) {
        SysUser user = sysUserMapper.selectById(userId);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        assertSameTenant(user);
        user.setRealName(realName);
        sysUserMapper.updateById(user);
        redisService.delete(RedisKeys.userCache(user.getUsername()));
    }

    /** 删除用户，禁止删除 admin 账号 */
    @Override
    public void delete(Long id) {
        SysUser user = sysUserMapper.selectById(id);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        assertSameTenant(user);
        if ("admin".equals(user.getUsername())) {
            throw new BizException("admin 不允许删除");
        }
        sysUserMapper.deleteById(id);
        redisService.delete(RedisKeys.userCache(user.getUsername()));
    }

    /** 用户自助修改密码，需校验原密码 */
    @Override
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        if (!StringUtils.hasText(oldPassword) || !StringUtils.hasText(newPassword)) {
            throw new BizException("密码不能为空");
        }
        if (newPassword.length() < 6) {
            throw new BizException("新密码长度不能少于 6 位");
        }

        SysUser user = sysUserMapper.selectById(userId);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        assertSameTenant(user);
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BizException("原密码错误");
        }
        if (oldPassword.equals(newPassword)) {
            throw new BizException("新密码不能与原密码相同");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        sysUserMapper.updateById(user);
        redisService.delete(RedisKeys.userCache(user.getUsername()));
    }

    /** 管理员重置用户密码，无需原密码 */
    @Override
    public void resetPassword(Long id, String newPassword) {
        if (!StringUtils.hasText(newPassword)) {
            throw new BizException("新密码不能为空");
        }
        SysUser user = sysUserMapper.selectById(id);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        assertSameTenant(user);
        user.setPassword(passwordEncoder.encode(newPassword));
        sysUserMapper.updateById(user);
        redisService.delete(RedisKeys.userCache(user.getUsername()));
    }
}