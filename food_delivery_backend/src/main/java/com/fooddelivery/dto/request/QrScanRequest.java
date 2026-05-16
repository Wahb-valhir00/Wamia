package com.fooddelivery.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class QrScanRequest {

    @NotBlank(message = "QR token is required")
    private String qrToken;
}
