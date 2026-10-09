package com.gov.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

/**
 * 修改个人信息请求。
 *
 * <p>原来用裸的 {@code @RequestBody Map<String, String>}，导致接口文档里请求体变成
 * 「任意键值对象」schema、Knife4j 以表单格式提交而无法调试；改成具名 DTO 后文档页正常。
 */
@Schema(description = "修改个人信息请求")
public class ProfileUpdateDTO {

    @Schema(description = "真实姓名", example = "张三", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotBlank(message = "姓名不能为空")
    private String realName;

    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
}
