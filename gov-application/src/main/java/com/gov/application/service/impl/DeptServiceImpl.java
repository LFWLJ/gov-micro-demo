package com.gov.application.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.gov.application.entity.Dept;
import com.gov.application.entity.SysUser;
import com.gov.application.mapper.DeptMapper;
import com.gov.application.mapper.SysUserMapper;
import com.gov.application.service.DeptService;
import com.gov.common.exception.BizException;
import com.gov.common.tenant.TenantContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 部门管理实现
 * <p>
 * 提供部门树构建、级联子部门查询、CRUD 等能力。
 * 所有写操作均按 {@code TenantContext} 填充 tenantId，
 * 读操作依赖 MyBatis-Plus 租户插件自动隔离。
 * 删除前做安全校验：有子部门或有用户关联时禁止删除。
 * </p>
 */
@Service
public class DeptServiceImpl implements DeptService {

    @Autowired
    private DeptMapper deptMapper;

    @Autowired
    private SysUserMapper sysUserMapper;

    /**
     * 构建部门树（一次查询 + 内存组装）
     * <p>
     * 查询全部部门后在 Java 内存里根据 parentId 组装成多叉树结构，
     * 返回根节点列表，每个节点的 {@code children} 字段携带子部门。
     * </p>
     */
    @Override
    public List<Dept> tree() {
        List<Dept> all = deptMapper.selectList(
                new LambdaQueryWrapper<Dept>()
                        .orderByAsc(Dept::getOrderNum)
                        .orderByAsc(Dept::getId));

        Map<Long, Dept> map = all.stream()
                .collect(Collectors.toMap(Dept::getId, d -> d, (a, b) -> a));
        List<Dept> roots = new ArrayList<>();
        for (Dept d : all) {
            Long pid = d.getParentId();
            if (pid == null || pid == 0 || !map.containsKey(pid)) {
                roots.add(d);
            } else {
                map.get(pid).getChildren().add(d);
            }
        }
        return roots;
    }

    /**
     * 递归查询指定部门及其所有子部门 ID（用于数据权限「本部门及以下」）
     */
    @Override
    public List<Long> getSelfAndChildIds(Long deptId) {
        List<Long> result = new ArrayList<>();
        result.add(deptId);
        collectChildren(deptId, result);
        return result;
    }

    private void collectChildren(Long parentId, List<Long> result) {
        List<Dept> children = deptMapper.selectList(
                new LambdaQueryWrapper<Dept>()
                        .eq(Dept::getParentId, parentId));
        for (Dept d : children) {
            result.add(d.getId());
            collectChildren(d.getId(), result);
        }
    }

    /** 创建部门，默认 parentId=0、orderNum=0、status=1 */
    @Override
    public Long create(Dept dept) {
        if (!StringUtils.hasText(dept.getDeptName())) {
            throw new BizException("部门名称不能为空");
        }
        if (dept.getParentId() == null) {
            dept.setParentId(0L);
        }
        if (dept.getOrderNum() == null) {
            dept.setOrderNum(0);
        }
        if (dept.getStatus() == null) {
            dept.setStatus(1);
        }
        dept.setTenantId(TenantContext.get());
        deptMapper.insert(dept);
        return dept.getId();
    }

    /** 更新部门，禁止 parentId 指向自身 */
    @Override
    public void update(Dept dept) {
        if (dept.getId() == null) {
            throw new BizException("部门ID不能为空");
        }
        Dept exist = deptMapper.selectById(dept.getId());
        if (exist == null) {
            throw new BizException("部门不存在");
        }
        if (dept.getId().equals(dept.getParentId())) {
            throw new BizException("上级部门不能是自己");
        }
        dept.setTenantId(exist.getTenantId());
        deptMapper.updateById(dept);
    }

    /** 删除部门，有子部门或有用户关联时禁止删除 */
    @Override
    public void delete(Long id) {
        Dept dept = deptMapper.selectById(id);
        if (dept == null) {
            throw new BizException("部门不存在");
        }
        Long childCount = deptMapper.selectCount(
                new LambdaQueryWrapper<Dept>()
                        .eq(Dept::getParentId, id));
        if (childCount > 0) {
            throw new BizException("该部门下有子部门，不允许删除");
        }
        Long userCount = sysUserMapper.selectCount(
                new LambdaQueryWrapper<SysUser>()
                        .eq(SysUser::getDeptId, id));
        if (userCount > 0) {
            throw new BizException("该部门下有用户，不允许删除");
        }
        deptMapper.deleteById(id);
    }
}