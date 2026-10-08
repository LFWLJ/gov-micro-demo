package com.gov.auth.service;

import com.gov.auth.dto.UserSaveDTO;
import com.gov.auth.entity.SysUser;

import java.util.List;
import java.util.Map;

public interface UserService {

    SysUser findByUsername(String username);

    SysUser findById(Long id);

    SysUser login(String username, String password);

    Map<String, Object> page(int page, int size, String keyword);

    /** 查询全部用户（跨租户、不分页），供下拉选择/分配用户等场景使用 */
    List<SysUser> allUsers();

    Long create(UserSaveDTO dto);

    void update(UserSaveDTO dto);

    void updateProfile(Long userId, String realName);

    void delete(Long id);

    void changePassword(Long userId, String oldPassword, String newPassword);

    void resetPassword(Long id, String newPassword);
}