part of 'role_cubit.dart';

@immutable
sealed class RoleState {}

final class RoleInitial extends RoleState {}

final class RoleSubmitted extends RoleState {}

final class RoleFail extends RoleState {
  final String errorMessage;

  RoleFail(this.errorMessage);
}

final class RoleLoaded extends RoleState {
  final List<Role> roles;

  RoleLoaded(this.roles);
}
