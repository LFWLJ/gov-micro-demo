package com.gov.api.feign;

import com.gov.api.dto.UserDTO;
import com.gov.common.result.R;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(
        name = "gov-auth",
        path = "/api/auth",
        contextId = "authFeignClient"
)
public interface AuthFeignClient {

    @GetMapping("/user/info")
    R<UserDTO> getUserInfo(@RequestParam("userId") Long userId);
}