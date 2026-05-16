package com.fooddelivery.controller;

import com.fooddelivery.domain.entity.User;
import com.fooddelivery.dto.response.ApiResponse;
import com.fooddelivery.dto.response.MenuItemResponse;
import com.fooddelivery.dto.response.RestaurantResponse;
import com.fooddelivery.service.RestaurantService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class RestaurantController {

    private final RestaurantService restaurantService;

    // ---- Public / Customer ----

    @GetMapping("/restaurants")
    public ResponseEntity<ApiResponse<List<RestaurantResponse>>> getAllRestaurants() {
        return ResponseEntity.ok(ApiResponse.ok(restaurantService.getAllRestaurants()));
    }

    @GetMapping("/restaurants/{id}/menu")
    public ResponseEntity<ApiResponse<List<MenuItemResponse>>> getRestaurantMenu(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(restaurantService.getRestaurantMenu(id)));
    }
}
