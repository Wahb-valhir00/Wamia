-- ============================================================
-- Food Delivery Database Schema
-- ============================================================

CREATE DATABASE IF NOT EXISTS food_delivery;
USE food_delivery;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       ENUM('ROLE_CUSTOMER', 'ROLE_RESTAURANT', 'ROLE_DRIVER') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Restaurants table
CREATE TABLE IF NOT EXISTS restaurants (
    id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    name     VARCHAR(150) NOT NULL,
    location VARCHAR(255) NOT NULL,
    owner_id BIGINT NOT NULL,
    CONSTRAINT fk_restaurant_owner FOREIGN KEY (owner_id) REFERENCES users(id)
);

-- Menu items table
CREATE TABLE IF NOT EXISTS menu_items (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(150) NOT NULL,
    price         DECIMAL(10, 2) NOT NULL,
    restaurant_id BIGINT NOT NULL,
    CONSTRAINT fk_menu_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Menu options table
CREATE TABLE IF NOT EXISTS menu_options (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    price        DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    menu_item_id BIGINT NOT NULL,
    CONSTRAINT fk_option_menuitem FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE
);

-- Drivers table
CREATE TABLE IF NOT EXISTS drivers (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    status  ENUM('ONLINE', 'OFFLINE', 'BUSY') NOT NULL DEFAULT 'OFFLINE',
    CONSTRAINT fk_driver_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id   BIGINT NOT NULL,
    restaurant_id BIGINT NOT NULL,
    driver_id     BIGINT,
    status        ENUM('CREATED','ACCEPTED','PREPARING','READY','ASSIGNED','PICKED_UP','DELIVERED') NOT NULL DEFAULT 'CREATED',
    total_price   DECIMAL(10, 2) NOT NULL,
    qr_token      VARCHAR(36) NOT NULL UNIQUE,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_customer   FOREIGN KEY (customer_id)   REFERENCES users(id),
    CONSTRAINT fk_order_restaurant FOREIGN KEY (restaurant_id) REFERENCES restaurants(id),
    CONSTRAINT fk_order_driver     FOREIGN KEY (driver_id)     REFERENCES drivers(id)
);

-- Order items table
CREATE TABLE IF NOT EXISTS order_items (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id    BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    quantity    INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_orderitem_order    FOREIGN KEY (order_id)     REFERENCES orders(id) ON DELETE CASCADE,
    CONSTRAINT fk_orderitem_menuitem FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
);

-- Order item options table
CREATE TABLE IF NOT EXISTS order_item_options (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_item_id BIGINT NOT NULL,
    menu_option_id BIGINT NOT NULL,
    CONSTRAINT fk_oioption_orderitem FOREIGN KEY (order_item_id)  REFERENCES order_items(id) ON DELETE CASCADE,
    CONSTRAINT fk_oioption_option    FOREIGN KEY (menu_option_id) REFERENCES menu_options(id)
);
