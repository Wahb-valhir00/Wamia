package com.fooddelivery.repository;

import com.fooddelivery.domain.entity.MenuOption;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MenuOptionRepository extends JpaRepository<MenuOption, Long> {
    List<MenuOption> findByMenuItemId(Long menuItemId);
}
