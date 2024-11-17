import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/model/user.dart';
import 'package:simple/page/user/add_user.dart';
import 'package:simple/page/user/edit_user.dart';
import 'package:simple/service/user_rest.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  UserCubit userCubit = UserCubit(UserRest());
  TextEditingController searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    userCubit.onUserInit();
  }

  void _onScroll() {
    if (_isBottom) userCubit.onUserFetched();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => userCubit,
      child: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserFail) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is! UsersLoaded) {
            return CircularProgressIndicator();
          } else {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Pengguna',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddUserPage(),
                            ),
                          );
                          if (result != null) userCubit.onUserInit();
                        },
                        icon: const Icon(Icons.add_circle),
                        tooltip: 'Tambah Pengguna',
                      ),
                    ],
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelText: 'Cari',
                      suffixIcon: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear',
                            onPressed: () {
                              searchController.clear();
                              userCubit.onUserInit();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: 'Search',
                            onPressed: () {
                              userCubit.onUserSearch(searchController.text);
                            },
                          ),
                        ],
                      ),
                    ),
                    controller: searchController,
                    onSubmitted: (_) =>
                        userCubit.onUserSearch(searchController.text),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Text(
                        'Menampilkan ${state.users.length} dari ${state.total} pengguna.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.hasReachedMax
                        ? state.users.length
                        : state.users.length + 1,
                    itemBuilder: (context, index) {
                      return index >= state.users.length
                          ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),
                            )
                          : userCard(state.users[index], context);
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget userCard(User user, BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(user.nama),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditUserPage(user: user),
            ),
          );
          if (result != null) {
            userCubit.onUserInit();
            searchController.clear();
          }
        },
      ),
    );
  }
}
