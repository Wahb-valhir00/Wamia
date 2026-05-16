package com.fooddelivery.controller;

import com.fooddelivery.domain.entity.User;
import com.fooddelivery.domain.enums.DriverStatus;
import com.fooddelivery.dto.response.ApiResponse;
import com.fooddelivery.service.DriverService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/driver")
@RequiredArgsConstructor
@PreAuthorize("hasRole('DRIVER')")
public class DriverController {

    private final DriverService driverService;

    @PutMapping("/status")
    public ResponseEntity<ApiResponse<Void>> updateStatus(
            @AuthenticationPrincipal User user,
            @RequestBody Map<String, String> body) {
        String statusStr = body.get("status");
        DriverStatus status = DriverStatus.valueOf(statusStr.toUpperCase());
        driverService.updateStatus(user, status);
        return ResponseEntity.ok(ApiResponse.ok("Status updated to " + status, null));
    }
}
