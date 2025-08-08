part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthFail extends AuthState {
  final String errorMessage;

  const AuthFail(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class CaptchaFail extends AuthState {
  final String errorMessage;

  const CaptchaFail(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class UserUnauthenticated extends AuthState {}

final class UserAuthenticated extends AuthState {
  final UserLoggedIn userLoggedIn;

  const UserAuthenticated({required this.userLoggedIn});

  @override
  List<Object> get props => [userLoggedIn];
}
