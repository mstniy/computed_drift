import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter/material.dart';

import '../database/database.dart';
import 'home/card.dart';

class SearchPage extends ComputedStatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Computed<List<TodoEntryWithCategory>>? _search;

  @override
  void initState() {
    _search = Computed.async(() => _controller.use.text.isNotEmpty
        ? AppDatabase.provider.use.search(_controller.use.text)
        : Future.value(<TodoEntryWithCategory>[])).unwrap;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      body: _search == null
          ? const Align(
              alignment: Alignment.center,
              child: Text('Enter text to start searching'),
            )
          : ComputedBuilder(
              builder: (context) {
                try {
                  final results = _search!.use;

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
