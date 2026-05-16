package com.fooddelivery.service;

import com.fooddelivery.domain.entity.Driver;
import com.fooddelivery.domain.entity.Restaurant;
import com.fooddelivery.domain.entity.User;
import com.fooddelivery.domain.enums.UserRole;
import com.fooddelivery.dto.request.LoginRequest;
import com.fooddelivery.dto.request.RegisterRequest;
import com.fooddelivery.dto.response.AuthResponse;
import com.fooddelivery.repository.DriverRepository;
import com.fooddelivery.repository.RestaurantRepository;
import com.fooddelivery.repository.UserRepository;
import com.fooddelivery.security.JwtUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;
    private final DriverRepository driverRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtils jwtUtils;
    private final AuthenticationManager authenticationManager;

    // @Lazy breaks the circular dependency:
    // SecurityConfig → AuthenticationManager → AuthService → @Lazy(AuthenticationManager)
    public AuthService(
            UserRepository userRepository,
            RestaurantRepository restaurantRepository,
            DriverRepository driverRepository,
            PasswordEncoder passwordEncoder,
            JwtUtils jwtUtils,
            @Lazy AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
        this.driverRepository = driverRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtils = jwtUtils;
        this.authenticationManager = authenticationManager;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email is already registered");
        }

        User user = User.builder()
                .name(request.getName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(request.getRole())
                .build();

        user = userRepository.save(user);

        if (request.getRole() == UserRole.ROLE_RESTAURANT) {
            String restaurantName = request.getRestaurantName() != null
                    ? request.getRestaurantName()
                    : request.getName() + "'s Restaurant";
            String location = request.getRestaurantLocation() != null
                    ? request.getRestaurantLocation()
                    : "Location not set";

            Restaurant restaurant = Restaurant.builder()
                    .name(restaurantName)
                    .location(location)
                    .owner(user)
                    .build();
            restaurantRepository.save(restaurant);

        } else if (request.getRole() == UserRole.ROLE_DRIVER) {
            Driver driver = Driver.builder().user(user).build();
            driverRepository.save(driver);
        }

        String token = jwtUtils.generateToken(user);
        return buildAuthResponse(user, token);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        String token = jwtUtils.generateToken(user);
        return buildAuthResponse(user, token);
    }

    private AuthResponse buildAuthResponse(User user, String token) {
        return AuthResponse.builder()
                .token(token)
                .role(user.getRole())
                .userId(user.getId())
                .name(user.getName())
                .build();
    }
}
