import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/driver_models.dart';

abstract class DriverRemoteDatasource {
  Future<List<DriverOrder>> getAssignedOrders();
  Future<void> updateStatus(String status);
  Future<void> confirmPickup(int orderId, String qrToken);
  Future<void> confirmDelivery(int orderId, String qrToken);
}

class DriverRemoteDatasourceImpl implements DriverRemoteDatasource {
  final ApiClient _client;
  DriverRemoteDatasourceImpl(this._client);

  @override
  Future<List<DriverOrder>> getAssignedOrders() async {
    final res = await _client.get(ApiConstants.driverOrders);
    return (res.data['data'] as List).map((e) => DriverOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> updateStatus(String status) async {
    await _client.put(ApiConstants.driverStatus, data: {'status': status});
  }

  @override
  Future<void> confirmPickup(int orderId, String qrToken) async {
    await _client.put(
      ApiConstants.pickupOrder(orderId),
      data: {'qrToken': qrToken},
    );
  }

  @override
  Future<void> confirmDelivery(int orderId, String qrToken) async {
    await _client.put(
      ApiConstants.deliverOrder(orderId),
      data: {'qrToken': qrToken},
    );
  }
}
