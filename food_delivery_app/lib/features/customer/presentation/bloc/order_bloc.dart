import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/customer_repository.dart';

// --- Events ---
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class PlaceOrder extends OrderEvent {
  final Cart cart;
  const PlaceOrder(this.cart);
  @override
  List<Object?> get props => [cart];
}

class FetchOrder extends OrderEvent {
  final int orderId;
  const FetchOrder(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

class FetchMyOrders extends OrderEvent {
  const FetchMyOrders();
}

// --- States ---
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}
class OrderLoading extends OrderState {}

class OrderPlaced extends OrderState {
  final OrderModel order;
  const OrderPlaced(this.order);
  @override
  List<Object?> get props => [order];
}

class OrderLoaded extends OrderState {
  final OrderModel order;
  const OrderLoaded(this.order);
  @override
  List<Object?> get props => [order];
}

class MyOrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  const MyOrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CustomerRepository _repository;

  OrderBloc(this._repository) : super(OrderInitial()) {
    on<PlaceOrder>(_onPlace);
    on<FetchOrder>(_onFetch);
    on<FetchMyOrders>(_onFetchMy);
  }

  Future<void> _onPlace(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await _repository.placeOrder(event.cart);
    result.when(
      success: (order) => emit(OrderPlaced(order)),
      failure: (err) => emit(OrderError(err)),
    );
  }

  Future<void> _onFetch(FetchOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await _repository.getOrder(event.orderId);
    result.when(
      success: (order) => emit(OrderLoaded(order)),
      failure: (err) => emit(OrderError(err)),
    );
  }

  Future<void> _onFetchMy(FetchMyOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    final result = await _repository.getMyOrders();
    result.when(
      success: (orders) => emit(MyOrdersLoaded(orders)),
      failure: (err) => emit(OrderError(err)),
    );
  }
}
