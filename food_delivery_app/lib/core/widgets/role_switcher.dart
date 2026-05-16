import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';
import '../constants/app_colors.dart';
import '../mock/mock_data.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/data/models/auth_models.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';

/// Floating debug overlay to switch roles instantly without re-login.
/// Only visible in mock mode.
class RoleSwitcher extends StatefulWidget {
  final Widget child;
  const RoleSwitcher({super.key, required this.child});

  @override
  State<RoleSwitcher> createState() => _RoleSwitcherState();
}

class _RoleSwitcherState extends State<RoleSwitcher> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!isMockMode) return widget.child;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Only show when authenticated (so we don't overlap login)
        if (authState is! AuthAuthenticated) return widget.child;

        return Stack(
          children: [
            widget.child,
            Positioned(
              right: 8,
              bottom: 90,
              child: SafeArea(
                child: _expanded ? _buildExpanded(context) : _buildCollapsed(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCollapsed() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = true),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
        ),
        child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('SWITCH ROLE',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              GestureDetector(
                onTap: () => setState(() => _expanded = false),
                child: const Icon(Icons.close, color: Colors.white54, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _RoleBtn(
            icon: Icons.person_rounded,
            label: 'Customer',
            color: AppColors.success,
            onTap: () => _switchTo(context, _customerSession(), '/customer/home'),
          ),
          const SizedBox(height: 6),
          _RoleBtn(
            icon: Icons.storefront_rounded,
            label: 'Restaurant',
            color: AppColors.primary,
            onTap: () => _switchTo(context, _restaurantSession(), '/restaurant/dashboard'),
          ),
          const SizedBox(height: 6),
          _RoleBtn(
            icon: Icons.delivery_dining_rounded,
            label: 'Driver',
            color: AppColors.warning,
            onTap: () => _switchTo(context, _driverSession(), '/driver/dashboard'),
          ),
        ],
      ),
    );
  }

  AuthResponse _customerSession() => const AuthResponse(
        token: mockToken,
        role: 'ROLE_CUSTOMER',
        userId: mockUserId,
        name: mockUserName,
      );

  AuthResponse _restaurantSession() => const AuthResponse(
        token: mockRestaurantToken,
        role: 'ROLE_RESTAURANT',
        userId: mockRestaurantUserId,
        name: mockRestaurantName,
      );

  AuthResponse _driverSession() => const AuthResponse(
        token: mockDriverToken,
        role: 'ROLE_DRIVER',
        userId: mockDriverUserId,
        name: mockDriverName,
      );

  Future<void> _switchTo(BuildContext context, AuthResponse session, String route) async {
    await SecureStorage.instance.saveAuthData(
      token: session.token,
      role: session.role,
      userId: session.userId,
      userName: session.name,
    );
    if (!context.mounted) return;
    context.read<AuthBloc>().add(ForceAuthState(AuthAuthenticated(session)));
    context.go(route);
    setState(() => _expanded = false);
  }
}

class _RoleBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _RoleBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
