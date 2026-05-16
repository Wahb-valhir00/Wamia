package com.fooddelivery.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
public class MenuItemResponse {
    private Long id;
    private String name;
    private BigDecimal price;
    private List<MenuOptionResponse> options;

    @Data
    @Builder
    public static class MenuOptionResponse {
        private Long id;
        private String name;
        private BigDecimal price;
    }
}
