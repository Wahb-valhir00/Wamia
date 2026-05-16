package com.fooddelivery.repository;

import com.fooddelivery.domain.entity.Driver;
import com.fooddelivery.domain.enums.DriverStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DriverRepository extends JpaRepository<Driver, Long> {
    Optional<Driver> findByUserId(Long userId);
    List<Driver> findByStatus(DriverStatus status);
    Optional<Driver> findFirstByStatus(DriverStatus status);
}
