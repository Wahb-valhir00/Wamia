package com.fooddelivery.repository;

import com.fooddelivery.domain.entity.Order;
import com.fooddelivery.domain.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    List<Order> findByCustomerIdOrderByCreatedAtDesc(Long customerId);

    List<Order> findByRestaurantIdOrderByCreatedAtDesc(Long restaurantId);

    @Query("SELECT o FROM Order o WHERE o.driver.id = :driverId AND o.status IN :statuses ORDER BY o.createdAt DESC")
    List<Order> findByDriverIdAndStatusIn(
            @Param("driverId") Long driverId,
            @Param("statuses") List<OrderStatus> statuses
    );

    Optional<Order> findByIdAndQrToken(Long id, String qrToken);
}
