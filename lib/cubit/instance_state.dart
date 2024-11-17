part of 'instance_cubit.dart';

@immutable
sealed class InstanceState {}

final class InstanceInitial extends InstanceState {}

final class InstanceSubmitted extends InstanceState {}

final class InstancesLoaded extends InstanceState {
  final List<Instance> instances;
  final bool hasReachedMax;
  final int total;

  InstancesLoaded({
    this.instances = const <Instance>[],
    this.hasReachedMax = false,
    this.total = 0,
  });

  InstancesLoaded copyWith({
    List<Instance>? instances,
    bool? hasReachedMax,
    int? total,
  }) {
    return InstancesLoaded(
      instances: instances ?? this.instances,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      total: total ?? this.total,
    );
  }
}

final class InstanceLoaded extends InstanceState {
  final Instance instance;

  InstanceLoaded(this.instance);
}

final class InstanceFail extends InstanceState {
  final String errorMessage;

  InstanceFail(this.errorMessage);
}
