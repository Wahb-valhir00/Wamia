package com.fooddelivery.dto.response;

import com.fooddelivery.domain.enums.OrderStatus;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class OrderResponse {
    private Long id;
    private OrderStatus status;
    private BigDecimal totalPrice;
    private String qrToken;
    private String restaurantName;
    private String customerName;
    private String driverName;
    private LocalDateTime createdAt;
    private List<OrderItemResponse> items;

    @Data
    @Builder
    public static class OrderItemResponse {
        private Long menuItemId;
        private String menuItemName;
        private Integer quantity;
        private List<String> optionNames;
    }
}
