import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/restaurant_models.dart';
import '../bloc/restaurant_dashboard_bloc.dart';

class MenuManagementScreen extends StatelessWidget {
  const MenuManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showAddEditDialog(context, null),
      ),
      body: BlocBuilder<RestaurantDashboardBloc, RestaurantDashboardState>(
        builder: (context, state) {
          if (state is RestaurantDashboardLoading) return const AppLoading();
          if (state is RestaurantDashboardError) return AppErrorWidget(message: state.message);
          if (state is MenuLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No menu items. Add your first item!'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: state.items.length,
              itemBuilder: (context, i) => _MenuItemTile(
                item: state.items[i],
                onEdit: () => _showAddEditDialog(context, state.items[i]),
                onDelete: () => _confirmDelete(context, state.items[i].id!),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, RestaurantMenuItem? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<RestaurantDashboardBloc>(),
        child: _AddEditMenuItemSheet(existing: existing),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this menu item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<RestaurantDashboardBloc>().add(DeleteMenuItem(id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final RestaurantMenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MenuItemTile({required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                if (item.options.isNotEmpty)
                  Text('${item.options.length} option(s)',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.driverColor), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.error), onPressed: onDelete),
        ],
      ),
    );
  }
}

class _AddEditMenuItemSheet extends StatefulWidget {
  final RestaurantMenuItem? existing;
  const _AddEditMenuItemSheet({this.existing});

  @override
  State<_AddEditMenuItemSheet> createState() => _AddEditMenuItemSheetState();
}

class _AddEditMenuItemSheetState extends State<_AddEditMenuItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final List<Map<String, TextEditingController>> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _priceCtrl.text = widget.existing!.price.toString();
      for (final opt in widget.existing!.options) {
        _addOptionRow(name: opt.name, price: opt.price.toString());
      }
    }
  }

  void _addOptionRow({String name = '', String price = ''}) {
    setState(() {
      _optionControllers.add({
        'name': TextEditingController(text: name),
        'price': TextEditingController(text: price),
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    for (final c in _optionControllers) {
      c['name']!.dispose();
      c['price']!.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final options = _optionControllers
        .where((c) => c['name']!.text.isNotEmpty)
        .map((c) => RestaurantMenuItemOption(
              name: c['name']!.text,
              price: double.tryParse(c['price']!.text) ?? 0,
            ))
        .toList();

    final item = RestaurantMenuItem(
      name: _nameCtrl.text,
      price: double.parse(_priceCtrl.text),
      options: options,
    );

    final bloc = context.read<RestaurantDashboardBloc>();
    if (widget.existing?.id != null) {
      bloc.add(UpdateMenuItem(widget.existing!.id!, item));
    } else {
      bloc.add(AddMenuItem(item));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.existing == null ? 'Add Menu Item' : 'Edit Menu Item',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _dec('Item Name', Icons.fastfood_outlined),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Price (\$)', Icons.attach_money),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Enter valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Options', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Option'),
                      onPressed: _addOptionRow,
                    ),
                  ],
                ),
                ..._optionControllers.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ctrl = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: ctrl['name'],
                            decoration: _dec('Option Name', Icons.label_outline),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: ctrl['price'],
                            keyboardType: TextInputType.number,
                            decoration: _dec('+\$Price', Icons.attach_money),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                          onPressed: () => setState(() => _optionControllers.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submit,
                    child: Text(
                      widget.existing == null ? 'Add Item' : 'Save Changes',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      );
}
