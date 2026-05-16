package com.fooddelivery.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Stub implementation — replace with real FCM calls when ready.
 * Inject FCM SDK here and call FirebaseMessaging.getInstance().send(...)
 */
@Slf4j
@Service
public class NotificationService {

    public void notifyCustomer(Long customerId, String title, String body) {
        log.info("[FCM] → Customer {}: [{}] {}", customerId, title, body);
        // TODO: Implement FCM push notification
        // Message message = Message.builder()
        //     .setToken(getFcmTokenForUser(customerId))
        //     .setNotification(Notification.builder().setTitle(title).setBody(body).build())
        //     .build();
        // FirebaseMessaging.getInstance().send(message);
    }

    public void notifyDriver(Long driverId, String title, String body) {
        log.info("[FCM] → Driver {}: [{}] {}", driverId, title, body);
    }

    public void notifyRestaurant(Long restaurantId, String title, String body) {
        log.info("[FCM] → Restaurant {}: [{}] {}", restaurantId, title, body);
    }
}
