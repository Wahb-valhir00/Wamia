package com.fooddelivery.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class MenuItemRequest {

    @NotBlank(message = "Name is required")
    private String name;

    @NotNull(message = "Price is required")
    @Positive(message = "Price must be positive")
    private BigDecimal price;

    private List<OptionRequest> options;

    @Data
    public static class OptionRequest {
        @NotBlank(message = "Option name is required")
        private String name;

        @NotNull(message = "Option price is required")
        private BigDecimal price;
    }
}
