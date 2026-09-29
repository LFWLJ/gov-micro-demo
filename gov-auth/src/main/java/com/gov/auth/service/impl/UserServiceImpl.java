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

    @Override
    public SysUser findByUsername(String username) {
        // ★ 安全：不再把整个 SysUser（含 bcrypt 哈希）缓存进 Redis。
        //   登录是低频操作，直查数据库即可；同时避免凭证外泄与缓存键的跨租户歧义。
        return sysUserMapper.selectOne(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getUsername, username));
    }

    @Override
    public SysUser findById(Long id) {
        SysUser user = sysUserMapper.selectById(id);
        if (user != null) {
            assertSameTenant(user);
        }
        return user;
    }

    @Override
    public SysUser login(String username, String password) {
        SysUser user = findByUsername(username);
        if (user == null) return null;
        if (user.getStatus() == null || user.getStatus() != 1) return null;

        if (passwordEncoder.matches(password, user.getPassword())) {
            return user;
        }

        // ★ 安全：已移除「哈希非 $2a$ 时用明文 equals 比对并自动升级」的分支。
        //   留着它等于把"库里存明文口令也能登录"永久保留在生产路径上。
        //   历史明文口令请用一次性迁移脚本处理，不要放进登录逻辑。
        return null;
    }

    @Override
    public Map<String, Object> page(int page, int size, String keyword) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        // ★ sys_user 被排除在租户拦截器外（登录需按用户名跨租户查询），此处必须显式隔离
        wrapper.eq(SysUser::getTenantId, requireTenant());
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

    /** 取当前租户，缺失直接失败 —— 绝不允许退化成"不过滤" */
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

    private void fillStatusLabels(List<SysUser> users) {
        for (SysUser u : users) {
            if (u.getStatus() == null) continue;
            u.setStatusLabel(u.getStatus() == 1 ? "启用" : "禁用");
        }
    }

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