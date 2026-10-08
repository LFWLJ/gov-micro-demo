package com.gov.application.mapper;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SysRoleMenuMapper {

    @Delete("DELETE FROM sys_role_menu WHERE role_id = #{roleId}")
    int deleteByRoleId(Long roleId);

    @Delete("DELETE FROM sys_role_menu WHERE menu_id = #{menuId}")
    int deleteByMenuId(Long menuId);

    @Select("SELECT menu_id FROM sys_role_menu WHERE role_id = #{roleId}")
    List<Long> selectMenuIdsByRoleId(Long roleId);

    @Insert("<script>" +
            "INSERT INTO sys_role_menu (role_id, menu_id) VALUES " +
            "<foreach collection='menuIds' item='menuId' separator=','>" +
            "(#{roleId}, #{menuId})" +
            "</foreach>" +
            "</script>")
    int batchInsert(@Param("roleId") Long roleId, @Param("menuIds") List<Long> menuIds);

    /** 全部启用菜单（含按钮权限）——新建 ROLE_ADMIN 时使用 */
    @Select("SELECT id FROM sys_menu WHERE status = 1 ORDER BY id")
    List<Long> selectAllMenuIds();

    /** 只含目录/菜单节点、**不含按钮权限**——新建普通角色时使用，避免预置危险操作 */
    @Select("SELECT id FROM sys_menu WHERE status = 1 AND menu_type != 'F' ORDER BY id")
    List<Long> selectNavigableMenuIds();
}