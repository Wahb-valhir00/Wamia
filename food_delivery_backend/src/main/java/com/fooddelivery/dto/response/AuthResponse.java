package com.fooddelivery.dto.response;

import com.fooddelivery.domain.enums.UserRole;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AuthResponse {
    private String token;
    private UserRole role;
    private Long userId;
    private String name;
}
