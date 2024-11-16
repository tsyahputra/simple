import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:simple/model/role.dart';

part 'role_state.dart';

class RoleCubit extends Cubit<RoleState> {
  RoleCubit() : super(RoleInitial());
}
