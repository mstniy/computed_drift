import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/material.dart';

import '../database/database.dart';
import 'home/card.dart';

class SearchPage extends ComputedWidget {
  final TextEditingController _controller = TextEditingController();
  late final Computed<Future<List<TodoEntryWithCategory>>?> _search;
  SearchPage({Key? key}) : super(key: key) {
    _search = Computed.async(() => _controller.use.text.isNotEmpty
        ? AppDatabase.provider.use.search(_controller.use.text)
        : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search for todos across all categories',
          ),
          textInputAction: TextInputAction.search,
          controller: _controller,
        ),
      ),
      body: _search.use == null
          ? const Align(
              alignment: Alignment.center,
              child: Text('Enter text to start searching'),
            )
          : ComputedBuilder(
              builder: (context) {
                final future = _search.use!;
                try {
                  final results = future.use;

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return TodoCard(results[index].entry);
                    },
                  );
                } on NoValueException {
                  return const CircularProgressIndicator();
                }
              },
            ),
    );
  }
}
