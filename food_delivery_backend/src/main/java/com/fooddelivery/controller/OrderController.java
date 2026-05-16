package com.fooddelivery.controller;

import com.fooddelivery.domain.entity.User;
import com.fooddelivery.dto.request.PlaceOrderRequest;
import com.fooddelivery.dto.request.QrScanRequest;
import com.fooddelivery.dto.response.ApiResponse;
import com.fooddelivery.dto.response.OrderResponse;
import com.fooddelivery.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    // ---- CUSTOMER ----

    @PostMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<ApiResponse<OrderResponse>> placeOrder(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody PlaceOrderRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Order placed successfully", orderService.placeOrder(user, request)));
    }

    @GetMapping("/my")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getMyOrders(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getCustomerOrders(user)));
    }

    // ---- RESTAURANT ----

    @GetMapping("/restaurant")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getRestaurantOrders(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getRestaurantOrders(user)));
    }

    @PutMapping("/{id}/accept")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<OrderResponse>> acceptOrder(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Order accepted", orderService.acceptOrder(id, user)));
    }

    @PutMapping("/{id}/prepare")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<OrderResponse>> prepareOrder(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Order is preparing", orderService.prepareOrder(id, user)));
    }

    @PutMapping("/{id}/ready")
    @PreAuthorize("hasRole('RESTAURANT')")
    public ResponseEntity<ApiResponse<OrderResponse>> markReady(
            @AuthenticationPrincipal User user,
            @PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok("Order is ready", orderService.markOrderReady(id, user)));
    }

    // ---- DRIVER ----

    @GetMapping("/driver")
    @PreAuthorize("hasRole('DRIVER')")
    public ResponseEntity<ApiResponse<List<OrderResponse>>> getDriverOrders(
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getDriverOrders(user)));
    }

    @PutMapping("/{id}/pickup")
    @PreAuthorize("hasRole('DRIVER')")
    public ResponseEntity<ApiResponse<OrderResponse>> confirmPickup(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @Valid @RequestBody QrScanRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Pickup confirmed", orderService.confirmPickup(id, user, request.getQrToken())));
    }

    @PutMapping("/{id}/deliver")
    @PreAuthorize("hasRole('DRIVER')")
    public ResponseEntity<ApiResponse<OrderResponse>> confirmDelivery(
            @AuthenticationPrincipal User user,
            @PathVariable Long id,
            @Valid @RequestBody QrScanRequest request) {
        return ResponseEntity.ok(ApiResponse.ok("Delivery confirmed", orderService.confirmDelivery(id, user, request.getQrToken())));
    }

    // ---- SHARED ----

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<OrderResponse>> getOrder(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(orderService.getOrder(id)));
    }
}
