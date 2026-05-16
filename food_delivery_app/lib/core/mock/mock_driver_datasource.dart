import '../../features/driver/data/datasources/driver_remote_datasource.dart';
import '../../features/driver/data/models/driver_models.dart';
import 'mock_order_service.dart';

class MockDriverDatasource implements DriverRemoteDatasource {
  @override
  Future<List<DriverOrder>> getAssignedOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockOrderService.instance
        .getDriverOrders()
        .map((o) => o.toDriverOrder())
        .toList();
  }

  @override
  Future<void> updateStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    // No-op in mock mode
  }

  @override
  Future<void> confirmPickup(int orderId, String qrToken) async {
    await Future.delayed(const Duration(milliseconds: 250));
    MockOrderService.instance.pickUpOrder(orderId);
  }

  @override
  Future<void> confirmDelivery(int orderId, String qrToken) async {
    await Future.delayed(const Duration(milliseconds: 250));
    MockOrderService.instance.deliverOrder(orderId);
  }
}
