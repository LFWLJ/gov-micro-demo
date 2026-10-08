package com.gov.api.feign;

import com.gov.api.dto.UserDTO;
import com.gov.common.result.R;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 认证服务 Feign 客户端
 * <p>
 * 供其他微服务调用 auth 服务内部接口。
 * 所有 Feign 调用会自动通过 {@link com.gov.api.config.FeignTokenInterceptor}
 * 透传当前请求的 Authorization、租户、用户等上下文头。
 * </p>
 *
 * @see com.gov.api.config.FeignTokenInterceptor
 */
@FeignClient(
        name = "gov-auth",
        path = "/api/auth",
        contextId = "authFeignClient"
)
public interface AuthFeignClient {

    /**
     * 按用户 ID 查询用户信息
     * <p>
     * 对应 auth 服务的 {@code GET /api/auth/user/info}。
     * </p>
     *
     * @param userId 用户 ID
     * @return 用户 DTO
     */
    @GetMapping("/user/info")
    R<UserDTO> getUserInfo(@RequestParam("userId") Long userId);
}