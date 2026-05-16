package com.fooddelivery.controller;

import com.fooddelivery.domain.entity.User;
import com.fooddelivery.dto.request.MenuItemRequest;
import com.fooddelivery.dto.response.ApiResponse;
import com.fooddelivery.dto.response.MenuItemResponse;
import com.fooddelivery.service.RestaurantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/menu-items")
@RequiredArgsConstructor
@PreAuthorize("hasRole('RESTAURANT')")
public class MenuItemController {

    private final RestaurantService restaurantService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<MenuItemResponse>>> getMyMenu(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.ok(restaurantService.getMenuByOwner(user)));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<MenuItemResponse>> addItem(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody MenuItemRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(restaurantService.addMenuItem(user, request)));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<MenuItemResponse>> updateItem(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @Valid @RequestBody MenuItemRequest request) {
        return ResponseEntity.ok(ApiResponse.ok(restaurantService.updateMenuItem(user, id, request)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteItem(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        restaurantService.deleteMenuItem(user, id);
        return ResponseEntity.ok(ApiResponse.ok("Menu item deleted", null));
    }
}
