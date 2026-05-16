import '../../../../core/utils/enums.dart';

class OrderModel {
  final int id;
  final OrderStatus status;
  final double totalPrice;
  final String? qrToken;
  final String restaurantName;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.status,
    required this.totalPrice,
    this.qrToken,
    required this.restaurantName,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int,
        status: OrderStatusX.fromString(json['status'] as String),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        qrToken: json['qrToken'] as String?,
        restaurantName: json['restaurantName'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );

  String get qrData => '{"orderId":$id,"qrToken":"${qrToken ?? ""}"}';
}
