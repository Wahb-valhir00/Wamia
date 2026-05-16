package com.fooddelivery.service;

import com.fooddelivery.domain.entity.*;
import com.fooddelivery.domain.enums.DriverStatus;
import com.fooddelivery.domain.enums.OrderStatus;
import com.fooddelivery.dto.request.PlaceOrderRequest;
import com.fooddelivery.dto.response.OrderResponse;
import com.fooddelivery.repository.*;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class OrderService {

    private final OrderRepository orderRepository;
    private final RestaurantRepository restaurantRepository;
    private final MenuItemRepository menuItemRepository;
    private final MenuOptionRepository menuOptionRepository;
    private final DriverRepository driverRepository;
    private final NotificationService notificationService;

    @Transactional
    public OrderResponse placeOrder(User customer, PlaceOrderRequest request) {
        Restaurant restaurant = restaurantRepository.findById(request.getRestaurantId())
                .orElseThrow(() -> new EntityNotFoundException("Restaurant not found"));

        Order order = Order.builder()
                .customer(customer)
                .restaurant(restaurant)
                .qrToken(UUID.randomUUID().toString())
                .build();

        BigDecimal total = BigDecimal.ZERO;

        for (PlaceOrderRequest.OrderItemRequest itemReq : request.getItems()) {
            MenuItem menuItem = menuItemRepository.findById(itemReq.getMenuItemId())
                    .orElseThrow(() -> new EntityNotFoundException("Menu item not found: " + itemReq.getMenuItemId()));

            OrderItem orderItem = OrderItem.builder()
                    .order(order)
                    .menuItem(menuItem)
                    .quantity(itemReq.getQuantity())
                    .build();

            BigDecimal itemPrice = menuItem.getPrice()
                    .multiply(BigDecimal.valueOf(itemReq.getQuantity()));

            if (itemReq.getOptionIds() != null) {
                for (Long optionId : itemReq.getOptionIds()) {
                    MenuOption option = menuOptionRepository.findById(optionId)
                            .orElseThrow(() -> new EntityNotFoundException("Menu option not found: " + optionId));

                    OrderItemOption itemOption = OrderItemOption.builder()
                            .orderItem(orderItem)
                            .menuOption(option)
                            .build();
                    orderItem.getOptions().add(itemOption);

                    itemPrice = itemPrice.add(option.getPrice().multiply(BigDecimal.valueOf(itemReq.getQuantity())));
                }
            }

            order.getItems().add(orderItem);
            total = total.add(itemPrice);
        }

        order.setTotalPrice(total);
        Order saved = orderRepository.save(order);

        log.info("Order #{} placed by customer {} for restaurant {}", saved.getId(), customer.getId(), restaurant.getId());
        return toOrderResponse(saved);
    }

    @Transactional
    public OrderResponse acceptOrder(Long orderId, User restaurantOwner) {
        Order order = getOrderAndVerifyRestaurantOwner(orderId, restaurantOwner);
        assertStatus(order, OrderStatus.CREATED);

        order.setStatus(OrderStatus.ACCEPTED);
        Order saved = orderRepository.save(order);

        notificationService.notifyCustomer(
                order.getCustomer().getId(),
                "Order Accepted",
                "Your order #" + orderId + " has been accepted!"
        );

        return toOrderResponse(saved);
    }

    @Transactional
    public OrderResponse prepareOrder(Long orderId, User restaurantOwner) {
        Order order = getOrderAndVerifyRestaurantOwner(orderId, restaurantOwner);
        assertStatus(order, OrderStatus.ACCEPTED);

        order.setStatus(OrderStatus.PREPARING);
        return toOrderResponse(orderRepository.save(order));
    }

    @Transactional
    public OrderResponse markOrderReady(Long orderId, User restaurantOwner) {
        Order order = getOrderAndVerifyRestaurantOwner(orderId, restaurantOwner);
        assertStatus(order, OrderStatus.PREPARING);

        order.setStatus(OrderStatus.READY);
        orderRepository.save(order);

        // Assign first available ONLINE driver
        assignDriver(order);

        Order saved = orderRepository.save(order);

        notificationService.notifyCustomer(
                order.getCustomer().getId(),
                "Order Ready",
                "Your order #" + orderId + " is ready! A driver has been assigned."
        );

        return toOrderResponse(saved);
    }

    private void assignDriver(Order order) {
        driverRepository.findFirstByStatus(DriverStatus.ONLINE).ifPresentOrElse(
                driver -> {
                    order.setDriver(driver);
                    order.setStatus(OrderStatus.ASSIGNED);
                    driver.setStatus(DriverStatus.BUSY);
                    driverRepository.save(driver);
                    log.info("Driver {} assigned to order {}", driver.getId(), order.getId());
                },
                () -> log.warn("No available driver found for order {}", order.getId())
        );
    }

    @Transactional
    public OrderResponse confirmPickup(Long orderId, User driverUser, String qrToken) {
        Order order = orderRepository.findByIdAndQrToken(orderId, qrToken)
                .orElseThrow(() -> new IllegalArgumentException("Invalid QR code or order ID"));

        Driver driver = driverRepository.findByUserId(driverUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Driver profile not found"));

        if (!order.getDriver().getId().equals(driver.getId())) {
            throw new SecurityException("This order is not assigned to you");
        }

        assertStatus(order, OrderStatus.ASSIGNED);
        order.setStatus(OrderStatus.PICKED_UP);

        return toOrderResponse(orderRepository.save(order));
    }

    @Transactional
    public OrderResponse confirmDelivery(Long orderId, User driverUser, String qrToken) {
        Order order = orderRepository.findByIdAndQrToken(orderId, qrToken)
                .orElseThrow(() -> new IllegalArgumentException("Invalid QR code or order ID"));

        Driver driver = driverRepository.findByUserId(driverUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Driver profile not found"));

        if (!order.getDriver().getId().equals(driver.getId())) {
            throw new SecurityException("This order is not assigned to you");
        }

        assertStatus(order, OrderStatus.PICKED_UP);
        order.setStatus(OrderStatus.DELIVERED);

        // Free up the driver
        driver.setStatus(DriverStatus.ONLINE);
        driverRepository.save(driver);

        return toOrderResponse(orderRepository.save(order));
    }

    public OrderResponse getOrder(Long orderId) {
        return toOrderResponse(orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException("Order not found")));
    }

    public List<OrderResponse> getCustomerOrders(User customer) {
        return orderRepository.findByCustomerIdOrderByCreatedAtDesc(customer.getId()).stream()
                .map(this::toOrderResponse)
                .toList();
    }

    public List<OrderResponse> getRestaurantOrders(User restaurantOwner) {
        Restaurant restaurant = restaurantRepository.findByOwnerId(restaurantOwner.getId())
                .orElseThrow(() -> new EntityNotFoundException("Restaurant not found"));
        return orderRepository.findByRestaurantIdOrderByCreatedAtDesc(restaurant.getId()).stream()
                .map(this::toOrderResponse)
                .toList();
    }

    public List<OrderResponse> getDriverOrders(User driverUser) {
        Driver driver = driverRepository.findByUserId(driverUser.getId())
                .orElseThrow(() -> new EntityNotFoundException("Driver profile not found"));
        return orderRepository.findByDriverIdAndStatusIn(
                driver.getId(),
                List.of(OrderStatus.ASSIGNED, OrderStatus.PICKED_UP)
        ).stream().map(this::toOrderResponse).toList();
    }

    // ---- Helpers ----

    private Order getOrderAndVerifyRestaurantOwner(Long orderId, User owner) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException("Order not found"));

        Restaurant restaurant = restaurantRepository.findByOwnerId(owner.getId())
                .orElseThrow(() -> new EntityNotFoundException("Restaurant not found"));

        if (!order.getRestaurant().getId().equals(restaurant.getId())) {
            throw new SecurityException("Order does not belong to your restaurant");
        }
        return order;
    }

    private void assertStatus(Order order, OrderStatus expected) {
        if (order.getStatus() != expected) {
            throw new IllegalStateException(
                    String.format("Order #%d must be in status %s but is %s",
                            order.getId(), expected, order.getStatus())
            );
        }
    }

    private OrderResponse toOrderResponse(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .status(order.getStatus())
                .totalPrice(order.getTotalPrice())
                .qrToken(order.getQrToken())
                .restaurantName(order.getRestaurant().getName())
                .customerName(order.getCustomer().getName())
                .driverName(order.getDriver() != null ? order.getDriver().getUser().getName() : null)
                .createdAt(order.getCreatedAt())
                .items(order.getItems().stream()
                        .map(item -> OrderResponse.OrderItemResponse.builder()
                                .menuItemId(item.getMenuItem().getId())
                                .menuItemName(item.getMenuItem().getName())
                                .quantity(item.getQuantity())
                                .optionNames(item.getOptions().stream()
                                        .map(o -> o.getMenuOption().getName())
                                        .toList())
                                .build())
                        .toList())
                .build();
    }
}
