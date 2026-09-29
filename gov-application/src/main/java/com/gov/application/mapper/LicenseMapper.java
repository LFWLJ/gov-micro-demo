package com.gov.application.mapper;

import com.baomidou.mybatisplus.annotation.InterceptorIgnore;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gov.application.entity.License;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface LicenseMapper extends BaseMapper<License> {

    /**
     * 按验真码查询（供公开验真接口使用）。
     *
     * <p>验真码在 {@code t_license} 上有全局唯一索引 {@code uk_verify_code}，且公开验真接口
     * 位于网关白名单（{@code /api/license/verify/**}），调用时没有任何租户上下文。
     * 若不显式跳过租户拦截器，SQL 会被改写为 {@code tenant_id = '__NONE__'}，
     * 导致公开验真永远返回"证照不存在"。
     */
    @InterceptorIgnore(tenantLine = "true")
    @Select("SELECT * FROM t_license WHERE verify_code = #{verifyCode} LIMIT 1")
    License selectByVerifyCodeAcrossTenant(@Param("verifyCode") String verifyCode);
}
