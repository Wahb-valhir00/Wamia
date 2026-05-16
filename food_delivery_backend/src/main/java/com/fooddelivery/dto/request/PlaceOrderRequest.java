package com.fooddelivery.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.util.List;

@Data
public class PlaceOrderRequest {

    @NotNull(message = "Restaurant ID is required")
    private Long restaurantId;

    @NotEmpty(message = "Order must have at least one item")
    private List<OrderItemRequest> items;

    @Data
    public static class OrderItemRequest {
        @NotNull
        private Long menuItemId;

        @Positive(message = "Quantity must be at least 1")
        private Integer quantity;

        private List<Long> optionIds;
    }
}
