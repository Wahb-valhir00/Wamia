package com.fooddelivery.controller;

import com.fooddelivery.domain.entity.User;
import com.fooddelivery.dto.response.ApiResponse;
import com.fooddelivery.dto.response.OrderResponse;
import com.fooddelivery.service.OrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/restaurant")
@RequiredArgsConstructor
@PreAuthorize("hasRole('RESTAURANT')")
public class RestaurantDashboardController {

    private final OrderService orderService;

    @GetMapping("/orders")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getOrders(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getRestaurantOrders(user)));
    }
}
