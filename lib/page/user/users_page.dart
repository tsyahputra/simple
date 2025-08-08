import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/user_cubit.dart';
import 'package:simple/model/user.dart';
import 'package:simple/page/user/add_user.dart';
import 'package:simple/page/user/edit_user.dart';
import 'package:simple/page/widget/loading_indicator.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  TextEditingController searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().onUserInit();
    });
  }

  void _onScroll() {
    if (_isBottom) context.read<UserCubit>().onUserFetched();
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
    return BlocConsumer<UserCubit, UserState>(
      listener: (context, state) {
        if (state is UserFail) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      builder: (context, state) {
        if (state is! UsersLoaded) {
          return LoadingIndicator();
        } else {
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
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
                            builder: (context) => AddUserPage(),
                          ),
                        );
                        if (result != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<UserCubit>().onUserInit();
                          });
                        }
                      },
                      icon: Icon(Icons.add_circle),
                      tooltip: 'Tambah Pengguna',
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
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
                          icon: Icon(Icons.clear),
                          tooltip: 'Clear',
                          onPressed: () {
                            searchController.clear();
                            context.read<UserCubit>().onUserInit();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          tooltip: 'Search',
                          onPressed: () {
                            context.read<UserCubit>().onUserSearch(
                              searchController.text,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  controller: searchController,
                  onSubmitted: (_) => context.read<UserCubit>().onUserSearch(
                    searchController.text,
                  ),
                ),
                SizedBox(height: 12.0),
                Row(
                  children: [
                    Text(
                      'Menampilkan ${state.users.length} dari ${state.total} pengguna.',
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.hasReachedMax
                      ? state.users.length
                      : state.users.length + 1,
                  itemBuilder: (context, index) {
                    return index >= state.users.length
                        ? LoadingIndicator()
                        : userCard(state.users[index], context);
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget userCard(User user, BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.person)),
        title: Text(user.nama),
        subtitle: Text(user.email),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditUserPage(user: user)),
          );
          if (result != null) {
            searchController.clear();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<UserCubit>().onUserInit();
            });
          }
        },
      ),
    );
  }
}
