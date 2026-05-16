import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/storage/secure_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheck);
    on<LoginSubmitted>(_onLogin);
    on<RegisterSubmitted>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<ForceAuthState>((e, emit) => emit(e.state as AuthState));
  }

  Future<void> _onAuthCheck(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      final storage = SecureStorage.instance;
      final role = await storage.getRole() ?? '';
      final name = await storage.getUserName() ?? '';
      final userId = await storage.getUserId() ?? 0;
      final token = await storage.getToken() ?? '';
      emit(AuthAuthenticated(AuthResponse(
        token: token,
        role: role,
        userId: userId,
        name: name,
      )));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.login(
      LoginRequest(email: event.email, password: event.password),
    );
    result.when(
      success: (data) => emit(AuthAuthenticated(data)),
      failure: (err) => emit(AuthError(err)),
    );
  }

  Future<void> _onRegister(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _repository.register(
      RegisterRequest(
        name: event.name,
        email: event.email,
        password: event.password,
        role: event.role,
      ),
    );
    result.when(
      success: (data) => emit(AuthAuthenticated(data)),
      failure: (err) => emit(AuthError(err)),
    );
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
