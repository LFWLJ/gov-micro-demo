package com.gov.application.mapper;

import com.baomidou.mybatisplus.annotation.InterceptorIgnore;
import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Constants;
import com.gov.application.entity.SysRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SysRoleMapper extends BaseMapper<SysRole> {

    /**
     * 分页查询角色，**跨租户**（列表页需要看到全部租户的角色）。
     *
     * <p>只豁免租户条件、不豁免分页；角色标识 roleKey 本身也已经要求全租户唯一。
     * 写操作（新增/修改/删除/分配菜单/分配用户）**仍然走默认的租户过滤**，
     * 因此这里"看得见"不等于"改得动"——操作别家租户的角色时会被判为不存在。
     */
    @InterceptorIgnore(tenantLine = "true")
    @Select("SELECT * FROM sys_role ${ew.customSqlSegment}")
    IPage<SysRole> selectPageAcrossTenant(IPage<SysRole> page,
                                          @Param(Constants.WRAPPER) Wrapper<SysRole> queryWrapper);

    /**
     * 查询全部角色，**跨租户、不分页**（供下拉选择等场景）。
     * 同样只豁免租户条件，写操作保持默认过滤。
     */
    @InterceptorIgnore(tenantLine = "true")
    @Select("SELECT * FROM sys_role ${ew.customSqlSegment}")
    List<SysRole> selectListAcrossTenant(@Param(Constants.WRAPPER) Wrapper<SysRole> queryWrapper);
}
