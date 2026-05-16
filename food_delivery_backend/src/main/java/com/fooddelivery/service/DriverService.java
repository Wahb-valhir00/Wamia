package com.fooddelivery.service;

import com.fooddelivery.domain.entity.Driver;
import com.fooddelivery.domain.entity.User;
import com.fooddelivery.domain.enums.DriverStatus;
import com.fooddelivery.repository.DriverRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class DriverService {

    private final DriverRepository driverRepository;

    @Transactional
    public void updateStatus(User driverUser, DriverStatus status) {
        Driver driver = driverRepository.findByUserId(driverUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Driver profile not found"));

        // Don't allow manual BUSY status — that's set by order assignment
        if (status == DriverStatus.BUSY) {
            throw new IllegalArgumentException("Cannot manually set status to BUSY");
        }

        driver.setStatus(status);
        driverRepository.save(driver);
    }
}
