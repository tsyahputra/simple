part of 'user_cubit.dart';

@immutable
sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserSubmitted extends UserState {}

final class UserChanged extends UserState {}

final class UserFail extends UserState {
  final String errorMessage;

  const UserFail(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class UsersLoaded extends UserState {
  final List<User> users;
  final bool hasReachedMax;
  final int total;

  const UsersLoaded({
    required this.users,
    required this.hasReachedMax,
    required this.total,
  });

  @override
  List<Object> get props => [users, hasReachedMax, total];
}

final class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

final class BeforeAddUser extends UserState {
  final InstancesRoles instancesRoles;

  const BeforeAddUser(this.instancesRoles);

  @override
  List<Object> get props => [instancesRoles];
}

final class TwoFASecretGenerated extends UserState {
  final TwoFASecret twoFASecret;

  const TwoFASecretGenerated(this.twoFASecret);

  @override
  List<Object> get props => [twoFASecret];
}

final class ResetTokenReceived extends UserState {
  final String resetToken;

  const ResetTokenReceived(this.resetToken);

  @override
  List<Object> get props => [resetToken];
}
