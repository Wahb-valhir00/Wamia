import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isOpen = true;
  bool _soundEnabled = true;
  bool _autoAccept = false;
  String _name = '';

  @override
  void initState() {
    super.initState();
    SecureStorage.instance.getUserName().then((n) {
      if (mounted) setState(() => _name = n ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile card ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_name.isEmpty ? 'Restaurant' : _name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      const Text('Restaurant Account',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Open / Close toggle ──
          const _SectionLabel('Store Status'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isOpen
                    ? AppColors.success.withOpacity(0.3)
                    : AppColors.error.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: (_isOpen ? AppColors.success : AppColors.error).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isOpen ? Icons.storefront_rounded : Icons.store_mall_directory_outlined,
                    color: _isOpen ? AppColors.success : AppColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOpen ? 'Store is Open' : 'Store is Closed',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _isOpen ? AppColors.success : AppColors.error,
                        ),
                      ),
                      Text(
                        _isOpen
                            ? 'Accepting new orders'
                            : 'Not accepting orders',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _isOpen,
                  activeColor: AppColors.success,
                  inactiveThumbColor: AppColors.error,
                  onChanged: (v) {
                    setState(() => _isOpen = v);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(v ? 'Store is now Open ✓' : 'Store is now Closed'),
                      backgroundColor: v ? AppColors.success : AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Preferences ──
          const _SectionLabel('Preferences'),
          const SizedBox(height: 8),
          _PrefTile(
            icon: Icons.volume_up_rounded,
            iconColor: AppColors.statusAccepted,
            title: 'Order Sound Alerts',
            subtitle: 'Play sound for new orders',
            trailing: Switch.adaptive(
              value: _soundEnabled,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _soundEnabled = v),
            ),
          ),
          const SizedBox(height: 8),
          _PrefTile(
            icon: Icons.auto_mode_rounded,
            iconColor: AppColors.statusPreparing,
            title: 'Auto-Accept Orders',
            subtitle: 'Automatically accept incoming orders',
            trailing: Switch.adaptive(
              value: _autoAccept,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _autoAccept = v),
            ),
          ),

          const SizedBox(height: 20),

          // ── Info ──
          const _SectionLabel('About'),
          const SizedBox(height: 8),
          _InfoTile(icon: Icons.info_outline_rounded, label: 'App Version', value: '1.0.0'),
          const SizedBox(height: 8),
          _InfoTile(icon: Icons.business_rounded, label: 'Powered by', value: 'Wamia Delivery'),

          const SizedBox(height: 20),

          // ── Logout ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () => _confirmLogout(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.5));
  }
}

class _PrefTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  const _PrefTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
