import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/restaurant_bloc.dart';
import '../../data/models/restaurant_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String _userName = '';
  int _selectedNav = 0;
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'icon': '🍕', 'label': 'Pizza'},
    {'icon': '🍔', 'label': 'Burgers'},
    {'icon': '🍣', 'label': 'Sushi'},
    {'icon': '🌮', 'label': 'Mexican'},
    {'icon': '🍜', 'label': 'Noodles'},
    {'icon': '🥗', 'label': 'Healthy'},
    {'icon': '🍰', 'label': 'Desserts'},
    {'icon': '☕', 'label': 'Drinks'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<RestaurantBloc>().add(const LoadRestaurants());
    _loadUser();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final name = await SecureStorage.instance.getUserName();
    if (mounted) setState(() => _userName = name ?? '');
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _selectedNav == 0
          ? _HomeTab(
              userName: _userName,
              greeting: _greeting(),
              categories: _categories,
              selectedCategory: _selectedCategory,
              searchController: _searchController,
              onCategoryTap: (i) => setState(() => _selectedCategory = i),
            )
          : _selectedNav == 1
              ? _buildOrdersTab()
              : _selectedNav == 2
                  ? _buildFavoritesTab()
                  : _buildProfileTab(),
      bottomNavigationBar: _BottomNav(
        selected: _selectedNav,
        onTap: (i) => setState(() => _selectedNav = i),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('My Orders',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📦', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Your orders will appear here',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push('/customer/orders');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('View All Orders'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Favorites',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('❤️', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('No favorites yet',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(_userName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Customer', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _ProfileTile(icon: Icons.receipt_long_outlined, label: 'My Orders',
              onTap: () => context.push('/customer/orders')),
          _ProfileTile(icon: Icons.location_on_outlined, label: 'Saved Addresses', onTap: () {}),
          _ProfileTile(icon: Icons.payment_outlined, label: 'Payment Methods', onTap: () {}),
          _ProfileTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
          _ProfileTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
          const SizedBox(height: 8),
          _ProfileTile(
            icon: Icons.logout,
            label: 'Sign Out',
            color: AppColors.error,
            onTap: () => context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatelessWidget {
  final String userName;
  final String greeting;
  final List<Map<String, dynamic>> categories;
  final int selectedCategory;
  final TextEditingController searchController;
  final ValueChanged<int> onCategoryTap;

  const _HomeTab({
    required this.userName,
    required this.greeting,
    required this.categories,
    required this.selectedCategory,
    required this.searchController,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async =>
            context.read<RestaurantBloc>().add(const LoadRestaurants()),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: _buildPromoBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('All Restaurants',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    Text('See all',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            _buildRestaurantList(context),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text('Deliver to',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Icon(Icons.keyboard_arrow_down,
                        size: 16, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Current Location',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Wamia Delivery 🛵',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 0.3)),
                    if (isMockMode) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.warning.withOpacity(0.4)),
                        ),
                        child: const Text('DEMO',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                                letterSpacing: 0.5)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('$greeting, ${userName.split(' ').first} 👋',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const Text('What are you craving today?',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: AppColors.textPrimary, size: 22),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search restaurants or dishes...',
            hintStyle:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            prefixIcon:
                const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 18),
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final isSelected = i == selectedCategory;
          return GestureDetector(
            onTap: () => onCategoryTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.3)
                        : AppColors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(categories[i]['icon'] as String,
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    categories[i]['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return const _PromoBanners();
  }

  Widget _buildRestaurantList(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        if (state is RestaurantLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => const _RestaurantCardSkeleton(),
              childCount: 4,
            ),
          );
        }
        if (state is RestaurantError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<RestaurantBloc>()
                        .add(const LoadRestaurants()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is RestaurantsLoaded) {
          if (state.restaurants.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Text('🍽️', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 16),
                    Text('No restaurants available yet',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  ],
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _RestaurantCard(
                restaurant: state.restaurants[index],
                index: index,
                onTap: () => context.push(
                    '/customer/restaurant/${state.restaurants[index].id}'),
              ),
              childCount: state.restaurants.length,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

// ─── Restaurant Card ─────────────────────────────────────────────────────────

class _RestaurantCard extends StatelessWidget {
  final RestaurantModel restaurant;
  final int index;
  final VoidCallback onTap;

  const _RestaurantCard({
    required this.restaurant,
    required this.index,
    required this.onTap,
  });

  static const List<List<Color>> _gradients = [
    [Color(0xFF3AB3A9), Color(0xFF56CFC4)],
    [Color(0xFF2C3E50), Color(0xFF3498DB)],
    [Color(0xFF27AE60), Color(0xFF2ECC71)],
    [Color(0xFF8E44AD), Color(0xFF9B59B6)],
    [Color(0xFF2A9A90), Color(0xFF3AB3A9)],
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];
    final deliveryTime = isMockMode
        ? (mockDeliveryTimes[restaurant.id] ?? '25–40 min')
        : '${20 + (index * 7) % 25}–${30 + (index * 7) % 25} min';
    final rating = isMockMode
        ? (mockRatings[restaurant.id] ?? '4.5')
        : (4.0 + (index * 0.3) % 1.0).toStringAsFixed(1);
    final minOrder = '\$${5 + index * 3}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Banner
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),
                // Open badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 7, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Open',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // Favourite
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border,
                        size: 18, color: AppColors.textSecondary),
                  ),
                ),
                // Delivery time chip
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(deliveryTime,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Color(0xFFF39C12)),
                            const SizedBox(width: 3),
                            Text(rating,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF39C12))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          restaurant.location,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(
                          icon: Icons.delivery_dining_outlined,
                          label: 'Free delivery'),
                      const SizedBox(width: 12),
                      _InfoChip(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Min $minOrder'),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Order',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ─── Skeleton Loader ─────────────────────────────────────────────────────────

class _RestaurantCardSkeleton extends StatefulWidget {
  const _RestaurantCardSkeleton();

  @override
  State<_RestaurantCardSkeleton> createState() =>
      _RestaurantCardSkeletonState();
}

class _RestaurantCardSkeletonState extends State<_RestaurantCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Opacity(
        opacity: _animation.value,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                height: 160,
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 16, width: 160,
                        decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 8),
                    Container(
                        height: 12, width: 240,
                        decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(8))),
                    const SizedBox(height: 12),
                    Container(
                        height: 12, width: 120,
                        decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home',
                  active: selected == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.receipt_long_rounded, label: 'Orders',
                  active: selected == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.favorite_rounded, label: 'Favorites',
                  active: selected == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile',
                  active: selected == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: 24,
                  color: active ? AppColors.primary : AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        active ? FontWeight.bold : FontWeight.normal,
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Profile Tile ─────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: c),
        ),
        title: Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: c)),
        trailing: color == null
            ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
            : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

// ─── Promo Banners ────────────────────────────────────────────────────────────

class _PromoBanners extends StatefulWidget {
  const _PromoBanners();

  @override
  State<_PromoBanners> createState() => _PromoBannersState();
}

class _PromoBannersState extends State<_PromoBanners> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  static const List<_BannerData> _banners = [
    _BannerData(
      asset: 'assets/images/banner1.jpg',
      tag: '🎉 LIMITED TIME',
      title: '20% OFF',
      subtitle: 'On all orders above \$15',
      tagColor: Color(0xFF3AB3A9),
    ),
    _BannerData(
      asset: 'assets/images/banner2.jpg',
      tag: '🚀 NEW',
      title: 'Free Delivery',
      subtitle: 'First 3 orders on us!',
      tagColor: Color(0xFF27AE60),
    ),
    _BannerData(
      asset: 'assets/images/banner3.jpg',
      tag: '⚡ FLASH DEAL',
      title: 'Buy 2 Get 1',
      subtitle: 'Every Friday & Saturday',
      tagColor: Color(0xFF2A9A90),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Column(
        children: [
          SizedBox(
            height: 175,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                final b = _banners[i];
                return AnimatedScale(
                  scale: _currentPage == i ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Banner image
                          Image.asset(
                            b.asset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    b.tagColor.withOpacity(0.8),
                                    b.tagColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          // Gradient overlay
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.55),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          // Text overlay
                          Positioned(
                            left: 18,
                            bottom: 18,
                            right: 18,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: b.tagColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(b.tag,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5)),
                                ),
                                const SizedBox(height: 6),
                                Text(b.title,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        height: 1.1,
                                        shadows: [
                                          Shadow(
                                              color: Colors.black45,
                                              blurRadius: 4,
                                              offset: Offset(0, 2))
                                        ])),
                                const SizedBox(height: 2),
                                Text(b.subtitle,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        shadows: [
                                          Shadow(
                                              color: Colors.black38,
                                              blurRadius: 4)
                                        ])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (i) {
              final active = i == _currentPage;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BannerData {
  final String asset;
  final String tag;
  final String title;
  final String subtitle;
  final Color tagColor;

  const _BannerData({
    required this.asset,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.tagColor,
  });
}
