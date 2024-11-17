import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../model/instance.dart';
import '../service/instance_rest.dart';

part 'instance_state.dart';

class InstanceCubit extends Cubit<InstanceState> {
  InstanceRest instanceRest;

  InstanceCubit(this.instanceRest) : super(InstanceInitial());

  void onInstanceInit() async {
    final instances = await instanceRest.getAllInstances(0, '');
    if (instances.instances.length < 10) {
      emit(InstancesLoaded(
        hasReachedMax: true,
        instances: instances.instances,
        total: instances.total,
      ));
    } else {
      emit(InstancesLoaded(
        hasReachedMax: false,
        instances: instances.instances,
        total: instances.total,
      ));
    }
  }

  void onInstanceFetched() async {
    Instances instances;
    try {
      InstancesLoaded instancesLoaded = state as InstancesLoaded;
      if (instancesLoaded.hasReachedMax) return;
      instances = await instanceRest.getAllInstances(
        instancesLoaded.instances.length,
        '',
      );
      instances.instances.isEmpty
          ? emit(InstancesLoaded(
              hasReachedMax: true,
              instances: instancesLoaded.instances,
              total: instancesLoaded.total,
            ))
          : emit(InstancesLoaded(
              hasReachedMax: false,
              instances: instancesLoaded.instances + instances.instances,
              total: instancesLoaded.total,
            ));
    } on Exception catch (_) {
      emit(InstanceFail('Gagal'));
    }
  }

  void onInstanceSearch(String lastSearchTerm) async {
    final instances = await instanceRest.getAllInstances(0, lastSearchTerm);
    emit(InstancesLoaded(
      hasReachedMax: true,
      instances: instances.instances,
      total: instances.total,
    ));
  }

  void viewInstance(int instanceId) async {
    var result = await instanceRest.viewInstance(instanceId);
    result.fold(
      (l) => emit(InstanceFail(l)),
      (r) => emit(InstanceLoaded(r)),
    );
  }

  void addInstance(Instance instance) async {
    var result = await instanceRest.addInstance(instance);
    result.fold(
      (l) => emit(InstanceFail(l)),
      (_) => emit(InstanceSubmitted()),
    );
  }

  void editInstance(Instance instance) async {
    var result = await instanceRest.editInstance(instance);
    result.fold(
      (l) => emit(InstanceFail(l)),
      (_) => emit(InstanceSubmitted()),
    );
  }

  void deleteInstance(int id) async {
    var result = await instanceRest.deleteInstance(id);
    result.fold(
      (l) => emit(InstanceFail(l)),
      (_) => emit(InstanceSubmitted()),
    );
  }
}
