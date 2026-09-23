package com.gov.auth.service;

import com.gov.auth.dto.UserSaveDTO;
import com.gov.auth.entity.SysUser;

import java.util.Map;

public interface UserService {

    SysUser findByUsername(String username);

    SysUser findById(Long id);

    SysUser login(String username, String password);

    Map<String, Object> page(int page, int size, String keyword);

    Long create(UserSaveDTO dto);

    void update(UserSaveDTO dto);

    void updateProfile(Long userId, String realName);

    void delete(Long id);

    void changePassword(Long userId, String oldPassword, String newPassword);

    void resetPassword(Long id, String newPassword);
}