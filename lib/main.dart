import 'package:flutter/material.dart';
import 'package:infinite_list/post.dart';
import 'package:infinite_list/repository.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InfiniteList(),
    );
  }
}

class InfiniteList extends StatefulWidget {
  const InfiniteList({Key? key}) : super(key: key);

  @override
  State<InfiniteList> createState() => _InfiniteListState();
}

class _InfiniteListState extends State<InfiniteList> {
  int _initialCount = 20;
  final Repository _repository = Repository();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) _initialCount++;
    // setState(() {});
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
    return Scaffold(
      appBar: AppBar(title: const Text("Infinite List")),
      body: FutureBuilder<List<Post>>(
        future: _repository.getAllPosts(),
        builder: (context, snaps) {
          switch (snaps.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
            case ConnectionState.active:
              return ListView.builder(
                controller: _scrollController,
                itemCount: snaps.data!.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    leading: Text('${snaps.data![index].id}'),
                    title: Text(snaps.data![index].title),
                    isThreeLine: true,
                    subtitle: Text(snaps.data![index].body),
                    dense: true,
                  );
                },
              );
            default:
              return const Center(
                child: Text("Something went wrong"),
              );
          }
        },
      ),
    );
  }
}
