import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/driver_remote_datasource.dart';
import '../../data/models/driver_models.dart';

// --- Events ---
abstract class DriverEvent extends Equatable {
  const DriverEvent();
  @override
  List<Object?> get props => [];
}

class LoadDriverOrders extends DriverEvent {}
class UpdateDriverStatus extends DriverEvent {
  final String status;
  const UpdateDriverStatus(this.status);
  @override List<Object?> get props => [status];
}
class ConfirmPickup extends DriverEvent {
  final int orderId;
  final String qrToken;
  const ConfirmPickup({required this.orderId, required this.qrToken});
  @override List<Object?> get props => [orderId, qrToken];
}
class ConfirmDelivery extends DriverEvent {
  final int orderId;
  final String qrToken;
  const ConfirmDelivery({required this.orderId, required this.qrToken});
  @override List<Object?> get props => [orderId, qrToken];
}

// --- States ---
abstract class DriverState extends Equatable {
  const DriverState();
  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {}
class DriverLoading extends DriverState {}

class DriverOrdersLoaded extends DriverState {
  final List<DriverOrder> orders;
  final String currentStatus;
  const DriverOrdersLoaded({required this.orders, required this.currentStatus});
  @override List<Object?> get props => [orders, currentStatus];
}

class DriverActionSuccess extends DriverState {
  final String message;
  const DriverActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

class DriverError extends DriverState {
  final String message;
  const DriverError(this.message);
  @override List<Object?> get props => [message];
}

// --- Bloc ---
class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final DriverRemoteDatasource _datasource;
  String _currentStatus = 'OFFLINE';

  DriverBloc(this._datasource) : super(DriverInitial()) {
    on<LoadDriverOrders>(_onLoad);
    on<UpdateDriverStatus>(_onUpdateStatus);
    on<ConfirmPickup>(_onPickup);
    on<ConfirmDelivery>(_onDeliver);
  }

  Future<void> _onLoad(LoadDriverOrders event, Emitter<DriverState> emit) async {
    emit(DriverLoading());
    try {
      final orders = await _datasource.getAssignedOrders();
      emit(DriverOrdersLoaded(orders: orders, currentStatus: _currentStatus));
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(UpdateDriverStatus event, Emitter<DriverState> emit) async {
    try {
      await _datasource.updateStatus(event.status);
      _currentStatus = event.status;
      add(LoadDriverOrders());
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onPickup(ConfirmPickup event, Emitter<DriverState> emit) async {
    try {
      await _datasource.confirmPickup(event.orderId, event.qrToken);
      emit(const DriverActionSuccess('Pickup confirmed! Order is on the way.'));
      add(LoadDriverOrders());
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }

  Future<void> _onDeliver(ConfirmDelivery event, Emitter<DriverState> emit) async {
    try {
      await _datasource.confirmDelivery(event.orderId, event.qrToken);
      emit(const DriverActionSuccess('Delivery confirmed! Great job.'));
      add(LoadDriverOrders());
    } catch (e) {
      emit(DriverError(e.toString()));
    }
  }
}
