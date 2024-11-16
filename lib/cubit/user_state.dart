part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserSubmitted extends UserState {}

final class UserVerified extends UserState {}

final class CaptchaFail extends UserState {
  final String errorMessage;

  CaptchaFail(this.errorMessage);
}

final class UsersLoaded extends UserState {
  final List<User> users;
  final bool hasReachedMax;
  final int total;

  UsersLoaded({
    this.users = const <User>[],
    this.hasReachedMax = false,
    this.total = 0,
  });

  UsersLoaded copyWith({
    List<User>? users,
    bool? hasReachedMax,
    int? total,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      total: total ?? this.total,
    );
  }
}

final class UserLoaded extends UserState {
  final User user;

  UserLoaded(this.user);
}

final class BeforeAddUser extends UserState {
  final InstancesRoles instancesRoles;

  BeforeAddUser(this.instancesRoles);
}

final class UserAuthenticated extends UserState {
  final UserLoggedIn userLoggedIn;

  UserAuthenticated(this.userLoggedIn);
}

final class UserFail extends UserState {
  final String errorMessage;

  UserFail(this.errorMessage);
}
