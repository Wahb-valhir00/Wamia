package com.fooddelivery.service;

import com.fooddelivery.domain.entity.MenuItem;
import com.fooddelivery.domain.entity.MenuOption;
import com.fooddelivery.domain.entity.Restaurant;
import com.fooddelivery.domain.entity.User;
import com.fooddelivery.dto.request.MenuItemRequest;
import com.fooddelivery.dto.response.MenuItemResponse;
import com.fooddelivery.dto.response.RestaurantResponse;
import com.fooddelivery.repository.MenuItemRepository;
import com.fooddelivery.repository.RestaurantRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RestaurantService {

    private final RestaurantRepository restaurantRepository;
    private final MenuItemRepository menuItemRepository;

    public List<RestaurantResponse> getAllRestaurants() {
        return restaurantRepository.findAll().stream()
                .map(this::toRestaurantResponse)
                .toList();
    }

    public List<MenuItemResponse> getRestaurantMenu(Long restaurantId) {
        return menuItemRepository.findByRestaurantId(restaurantId).stream()
                .map(this::toMenuItemResponse)
                .toList();
    }

    public Restaurant getRestaurantByOwner(User owner) {
        return restaurantRepository.findByOwnerId(owner.getId())
                .orElseThrow(() -> new EntityNotFoundException("Restaurant not found for this owner"));
    }

    @Transactional
    public MenuItemResponse addMenuItem(User owner, MenuItemRequest request) {
        Restaurant restaurant = getRestaurantByOwner(owner);

        MenuItem item = MenuItem.builder()
                .name(request.getName())
                .price(request.getPrice())
                .restaurant(restaurant)
                .build();

        if (request.getOptions() != null) {
            for (MenuItemRequest.OptionRequest optReq : request.getOptions()) {
                MenuOption option = MenuOption.builder()
                        .name(optReq.getName())
                        .price(optReq.getPrice())
                        .menuItem(item)
                        .build();
                item.getOptions().add(option);
            }
        }

        return toMenuItemResponse(menuItemRepository.save(item));
    }

    @Transactional
    public MenuItemResponse updateMenuItem(User owner, Long itemId, MenuItemRequest request) {
        MenuItem item = menuItemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("Menu item not found"));

        // Verify ownership
        if (!item.getRestaurant().getOwner().getId().equals(owner.getId())) {
            throw new SecurityException("Not authorized to modify this menu item");
        }

        item.setName(request.getName());
        item.setPrice(request.getPrice());
        item.getOptions().clear();

        if (request.getOptions() != null) {
            for (MenuItemRequest.OptionRequest optReq : request.getOptions()) {
                MenuOption option = MenuOption.builder()
                        .name(optReq.getName())
                        .price(optReq.getPrice())
                        .menuItem(item)
                        .build();
                item.getOptions().add(option);
            }
        }

        return toMenuItemResponse(menuItemRepository.save(item));
    }

    @Transactional
    public void deleteMenuItem(User owner, Long itemId) {
        MenuItem item = menuItemRepository.findById(itemId)
                .orElseThrow(() -> new EntityNotFoundException("Menu item not found"));

        if (!item.getRestaurant().getOwner().getId().equals(owner.getId())) {
            throw new SecurityException("Not authorized to delete this menu item");
        }

        menuItemRepository.delete(item);
    }

    public List<MenuItemResponse> getMenuByOwner(User owner) {
        Restaurant restaurant = getRestaurantByOwner(owner);
        return menuItemRepository.findByRestaurantId(restaurant.getId()).stream()
                .map(this::toMenuItemResponse)
                .toList();
    }

    private RestaurantResponse toRestaurantResponse(Restaurant r) {
        return RestaurantResponse.builder()
                .id(r.getId())
                .name(r.getName())
                .location(r.getLocation())
                .build();
    }

    private MenuItemResponse toMenuItemResponse(MenuItem item) {
        return MenuItemResponse.builder()
                .id(item.getId())
                .name(item.getName())
                .price(item.getPrice())
                .options(item.getOptions().stream()
                        .map(o -> MenuItemResponse.MenuOptionResponse.builder()
                                .id(o.getId())
                                .name(o.getName())
                                .price(o.getPrice())
                                .build())
                        .toList())
                .build();
    }
}
