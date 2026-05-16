package com.fooddelivery.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "order_item_options")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderItemOption {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_item_id", nullable = false)
    private OrderItem orderItem;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "menu_option_id", nullable = false)
    private MenuOption menuOption;
}
