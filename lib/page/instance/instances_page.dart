import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple/cubit/instance_cubit.dart';
import 'package:simple/model/instance.dart';
import 'package:simple/page/instance/add_instance.dart';
import 'package:simple/page/instance/edit_instance.dart';
import 'package:simple/service/instance_rest.dart';

class InstancesPage extends StatefulWidget {
  const InstancesPage({super.key});

  @override
  State<InstancesPage> createState() => _InstancesPageState();
}

class _InstancesPageState extends State<InstancesPage> {
  InstanceCubit instanceCubit = InstanceCubit(InstanceRest());
  TextEditingController searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    instanceCubit.onInstanceInit();
  }

  void _onScroll() {
    if (_isBottom) instanceCubit.onInstanceFetched();
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
      create: (context) => instanceCubit,
      child: BlocConsumer<InstanceCubit, InstanceState>(
        listener: (context, state) {
          if (state is InstanceFail) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is! InstancesLoaded) {
            return Center(child: CircularProgressIndicator());
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
                        'Data Kantor',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: () async {
                          var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddInstancePage(),
                            ),
                          );
                          if (result != null) instanceCubit.onInstanceInit();
                        },
                        icon: const Icon(Icons.add_circle),
                        tooltip: 'Tambah Kantor',
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
                              instanceCubit.onInstanceInit();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: 'Search',
                            onPressed: () {
                              instanceCubit.onInstanceSearch(
                                searchController.text,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    controller: searchController,
                    onSubmitted: (_) =>
                        instanceCubit.onInstanceSearch(searchController.text),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: [
                      Text(
                        'Menampilkan ${state.instances.length} dari ${state.total} kantor.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: state.hasReachedMax
                        ? state.instances.length
                        : state.instances.length + 1,
                    itemBuilder: (context, index) {
                      return index >= state.instances.length
                          ? const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),
                            )
                          : daftarKantor(state.instances[index], context);
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

  Widget daftarKantor(Instance kantor, BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.apartment)),
        title: Text(kantor.nama),
        subtitle: Text(kantor.kabupaten!),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          var result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditInstancePage(instance: kantor),
            ),
          );
          if (result != null) {
            instanceCubit.onInstanceInit();
          }
        },
      ),
    );
  }
}
