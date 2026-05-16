import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/restaurant_remote_datasource.dart';
import '../../data/models/restaurant_models.dart';

// --- Events ---
abstract class RestaurantDashboardEvent extends Equatable {
  const RestaurantDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadRestaurantOrders extends RestaurantDashboardEvent {}
class AcceptOrder extends RestaurantDashboardEvent {
  final int orderId;
  const AcceptOrder(this.orderId);
  @override List<Object?> get props => [orderId];
}
class PrepareOrder extends RestaurantDashboardEvent {
  final int orderId;
  const PrepareOrder(this.orderId);
  @override List<Object?> get props => [orderId];
}
class MarkOrderReady extends RestaurantDashboardEvent {
  final int orderId;
  const MarkOrderReady(this.orderId);
  @override List<Object?> get props => [orderId];
}
class LoadMenu extends RestaurantDashboardEvent {}
class AddMenuItem extends RestaurantDashboardEvent {
  final RestaurantMenuItem item;
  const AddMenuItem(this.item);
  @override List<Object?> get props => [item];
}
class UpdateMenuItem extends RestaurantDashboardEvent {
  final int id;
  final RestaurantMenuItem item;
  const UpdateMenuItem(this.id, this.item);
  @override List<Object?> get props => [id, item];
}
class DeleteMenuItem extends RestaurantDashboardEvent {
  final int id;
  const DeleteMenuItem(this.id);
  @override List<Object?> get props => [id];
}

// --- States ---
abstract class RestaurantDashboardState extends Equatable {
  const RestaurantDashboardState();
  @override
  List<Object?> get props => [];
}

class RestaurantDashboardInitial extends RestaurantDashboardState {}
class RestaurantDashboardLoading extends RestaurantDashboardState {}

class OrdersLoaded extends RestaurantDashboardState {
  final List<RestaurantOrder> orders;
  const OrdersLoaded(this.orders);
  @override List<Object?> get props => [orders];
}

class MenuLoaded extends RestaurantDashboardState {
  final List<RestaurantMenuItem> items;
  const MenuLoaded(this.items);
  @override List<Object?> get props => [items];
}

class RestaurantDashboardError extends RestaurantDashboardState {
  final String message;
  const RestaurantDashboardError(this.message);
  @override List<Object?> get props => [message];
}

class OrderActionSuccess extends RestaurantDashboardState {
  final String message;
  const OrderActionSuccess(this.message);
  @override List<Object?> get props => [message];
}

// --- Bloc ---
class RestaurantDashboardBloc extends Bloc<RestaurantDashboardEvent, RestaurantDashboardState> {
  final RestaurantRemoteDatasource _datasource;

  RestaurantDashboardBloc(this._datasource) : super(RestaurantDashboardInitial()) {
    on<LoadRestaurantOrders>(_onLoadOrders);
    on<AcceptOrder>(_onAccept);
    on<PrepareOrder>(_onPrepare);
    on<MarkOrderReady>(_onReady);
    on<LoadMenu>(_onLoadMenu);
    on<AddMenuItem>(_onAddItem);
    on<UpdateMenuItem>(_onUpdateItem);
    on<DeleteMenuItem>(_onDeleteItem);
  }

  Future<void> _onLoadOrders(LoadRestaurantOrders event, Emitter<RestaurantDashboardState> emit) async {
    emit(RestaurantDashboardLoading());
    try {
      emit(OrdersLoaded(await _datasource.getOrders()));
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }

  Future<void> _onAccept(AcceptOrder event, Emitter<RestaurantDashboardState> emit) async {
    try {
      await _datasource.acceptOrder(event.orderId);
      emit(const OrderActionSuccess('Order accepted'));
      add(LoadRestaurantOrders());
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }

  Future<void> _onPrepare(PrepareOrder event, Emitter<RestaurantDashboardState> emit) async {
    try {
      await _datasource.prepareOrder(event.orderId);
      emit(const OrderActionSuccess('Order is preparing'));
      add(LoadRestaurantOrders());
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }

  Future<void> _onReady(MarkOrderReady event, Emitter<RestaurantDashboardState> emit) async {
    try {
      await _datasource.markReady(event.orderId);
      emit(const OrderActionSuccess('Order is ready — QR generated'));
      add(LoadRestaurantOrders());
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }

  Future<void> _onLoadMenu(LoadMenu event, Emitter<RestaurantDashboardState> emit) async {
    emit(RestaurantDashboardLoading());
    try {
      emit(MenuLoaded(await _datasource.getMenu()));
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }

  Future<void> _onAddItem(AddMenuItem event, Emitter<RestaurantDashboardState> emit) async {
    try {
      await _datasource.addMenuItem(event.item);
      add(LoadMenu());
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }

  Future<void> _onUpdateItem(UpdateMenuItem event, Emitter<RestaurantDashboardState> emit) async {
    try {
      await _datasource.updateMenuItem(event.id, event.item);
      add(LoadMenu());
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(DeleteMenuItem event, Emitter<RestaurantDashboardState> emit) async {
    try {
      await _datasource.deleteMenuItem(event.id);
      add(LoadMenu());
    } catch (e) {
      emit(RestaurantDashboardError(e.toString()));
    }
  }
}
