import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/menu_item_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/repositories/customer_repository.dart';

// --- Events ---
abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();
  @override
  List<Object?> get props => [];
}

class LoadRestaurants extends RestaurantEvent {
  const LoadRestaurants();
}

class LoadRestaurantMenu extends RestaurantEvent {
  final int restaurantId;
  const LoadRestaurantMenu(this.restaurantId);
  @override
  List<Object?> get props => [restaurantId];
}

// --- States ---
abstract class RestaurantState extends Equatable {
  const RestaurantState();
  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}
class RestaurantLoading extends RestaurantState {}

class RestaurantsLoaded extends RestaurantState {
  final List<RestaurantModel> restaurants;
  const RestaurantsLoaded(this.restaurants);
  @override
  List<Object?> get props => [restaurants];
}

class RestaurantMenuLoaded extends RestaurantState {
  final List<MenuItemModel> menu;
  const RestaurantMenuLoaded(this.menu);
  @override
  List<Object?> get props => [menu];
}

class RestaurantError extends RestaurantState {
  final String message;
  const RestaurantError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final CustomerRepository _repository;

  RestaurantBloc(this._repository) : super(RestaurantInitial()) {
    on<LoadRestaurants>(_onLoad);
    on<LoadRestaurantMenu>(_onLoadMenu);
  }

  Future<void> _onLoad(LoadRestaurants event, Emitter<RestaurantState> emit) async {
    emit(RestaurantLoading());
    final result = await _repository.getRestaurants();
    result.when(
      success: (data) => emit(RestaurantsLoaded(data)),
      failure: (err) => emit(RestaurantError(err)),
    );
  }

  Future<void> _onLoadMenu(LoadRestaurantMenu event, Emitter<RestaurantState> emit) async {
    emit(RestaurantLoading());
    final result = await _repository.getRestaurantMenu(event.restaurantId);
    result.when(
      success: (data) => emit(RestaurantMenuLoaded(data)),
      failure: (err) => emit(RestaurantError(err)),
    );
  }
}
