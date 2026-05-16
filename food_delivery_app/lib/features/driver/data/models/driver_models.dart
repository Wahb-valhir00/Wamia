import '../../../../core/utils/enums.dart';

class DriverOrder {
  final int id;
  final String customerName;
  final String restaurantName;
  final String restaurantLocation;
  final OrderStatus status;
  final double totalPrice;
  final String? qrToken;

  const DriverOrder({
    required this.id,
    required this.customerName,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.status,
    required this.totalPrice,
    this.qrToken,
  });

  factory DriverOrder.fromJson(Map<String, dynamic> json) => DriverOrder(
        id: json['id'] as int,
        customerName: json['customerName'] as String? ?? 'Customer',
        restaurantName: json['restaurantName'] as String? ?? '',
        restaurantLocation: json['restaurantLocation'] as String? ?? '',
        status: OrderStatusX.fromString(json['status'] as String),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        qrToken: json['qrToken'] as String?,
      );

  String get pickupQrData => '{"orderId":$id,"qrToken":"${qrToken ?? ""}"}';
}
