package com.gov.auth.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.auth.entity.SysUser;
import com.gov.auth.mapper.SysUserMapper;
import com.gov.common.redis.RedisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gov.auth.dto.UserSaveDTO;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import java.util.concurrent.TimeUnit;

@Service
public class UserService {

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private RedisService redisService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private static final String USER_CACHE_PREFIX = "user:info:";

    public SysUser findByUsername(String username) {
        String cacheKey = USER_CACHE_PREFIX + username;

        Object cached = redisService.get(cacheKey);
        if (cached instanceof SysUser) {
            return (SysUser) cached;
        }

        SysUser user = sysUserMapper.selectOne(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getUsername, username));

        if (user != null) {
            redisService.set(cacheKey, user, 10, TimeUnit.MINUTES);
        }
        return user;
    }

    public SysUser findById(Long id) {
        return sysUserMapper.selectById(id);
    }

    public SysUser login(String username, String password) {
        SysUser user = findByUsername(username);
        if (user == null) return null;
        if (user.getStatus() == null || user.getStatus() != 1) return null;

        if (passwordEncoder.matches(password, user.getPassword())) {
            return user;
        }

        if (!user.getPassword().startsWith("$2a$") && password.equals(user.getPassword())) {
            user.setPassword(passwordEncoder.encode(password));
            sysUserMapper.updateById(user);
            redisService.delete(USER_CACHE_PREFIX + username);
            return user;
        }

        return null;
    }

    /**
     * 分页查询用户（只查本租户）
     */
    public Map<String, Object> page(int page, int size, String keyword) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
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

    /**
     * 新增用户
     */
    public Long create(UserSaveDTO dto) {
        if (!StringUtils.hasText(dto.getUsername())) {
            throw new BizException("用户名不能为空");
        }
        if (!StringUtils.hasText(dto.getPassword())) {
            throw new BizException("密码不能为空");
        }
        // 用户名唯一性校验
        Long count = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getUsername, dto.getUsername()));
        if (count > 0) {
            throw new BizException("用户名已存在");
        }

        SysUser user = new SysUser();
        user.setUsername(dto.getUsername());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRealName(dto.getRealName());
        user.setTenantId(TenantContext.get());
        user.setRoles(dto.getRoles() == null ? "ROLE_USER" : dto.getRoles());
        user.setDeptId(dto.getDeptId());
        user.setDataScope(dto.getDataScope() == null ? 3 : dto.getDataScope());
        user.setStatus(dto.getStatus() == null ? 1 : dto.getStatus());

        sysUserMapper.insert(user);
        return user.getId();
    }

    /**
     * 修改用户
     */
    public void update(UserSaveDTO dto) {
        if (dto.getId() == null) {
            throw new BizException("用户ID不能为空");
        }
        SysUser user = sysUserMapper.selectById(dto.getId());
        if (user == null) {
            throw new BizException("用户不存在");
        }
        // 不允许改用户名（避免缓存混乱）
        user.setRealName(dto.getRealName());
        user.setRoles(dto.getRoles());
        user.setDeptId(dto.getDeptId());
        user.setDataScope(dto.getDataScope());
        user.setStatus(dto.getStatus());
        sysUserMapper.updateById(user);

        // 清缓存
        redisService.delete(USER_CACHE_PREFIX + user.getUsername());
    }

    /**
     * 修改个人信息
     */
    public void updateProfile(Long userId, String realName) {
        SysUser user = sysUserMapper.selectById(userId);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        user.setRealName(realName);
        sysUserMapper.updateById(user);
        // 清缓存
        redisService.delete(USER_CACHE_PREFIX + user.getUsername());
    }


    /**
     * 删除用户
     */
    public void delete(Long id) {
        SysUser user = sysUserMapper.selectById(id);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        if ("admin".equals(user.getUsername())) {
            throw new BizException("admin 不允许删除");
        }
        sysUserMapper.deleteById(id);
        redisService.delete(USER_CACHE_PREFIX + user.getUsername());
    }

    /**
     * 修改密码
     */
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
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new BizException("原密码错误");
        }
        if (oldPassword.equals(newPassword)) {
            throw new BizException("新密码不能与原密码相同");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        sysUserMapper.updateById(user);
        redisService.delete(USER_CACHE_PREFIX + user.getUsername());
    }

    /**
     * 重置密码
     */
    public void resetPassword(Long id, String newPassword) {
        if (!StringUtils.hasText(newPassword)) {
            throw new BizException("新密码不能为空");
        }
        SysUser user = sysUserMapper.selectById(id);
        if (user == null) {
            throw new BizException("用户不存在");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        sysUserMapper.updateById(user);
        redisService.delete(USER_CACHE_PREFIX + user.getUsername());
    }
}