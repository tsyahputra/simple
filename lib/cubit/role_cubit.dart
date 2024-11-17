import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:simple/model/role.dart';
import 'package:simple/service/role_rest.dart';

part 'role_state.dart';

class RoleCubit extends Cubit<RoleState> {
  RoleRest roleRest;

  RoleCubit(this.roleRest) : super(RoleInitial());

  void getAllRole() async {
    var result = await roleRest.getRoles();
    result.fold(
      (l) => emit(RoleFail(l)),
      (r) => emit(RoleLoaded(r)),
    );
  }

  void addRole(String nama) async {
    var result = await roleRest.addRole(nama);
    result.fold(
      (l) => emit(RoleFail(l)),
      (_) => emit(RoleSubmitted()),
    );
  }

  void editRole(Role role) async {
    var result = await roleRest.editRole(role);
    result.fold(
      (l) => emit(RoleFail(l)),
      (_) => emit(RoleSubmitted()),
    );
  }

  void deleteRole(int id) async {
    var result = await roleRest.deleteRole(id);
    result.fold(
      (l) => emit(RoleFail(l)),
      (_) => emit(RoleSubmitted()),
    );
  }
}
