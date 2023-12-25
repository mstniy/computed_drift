import 'package:computed_flutter/computed_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../database/database.dart';
import 'backup/backup.dart';
import 'home/card.dart';
import 'home/drawer.dart';
import 'home/state.dart';

class HomePage extends ComputedWidget {
  HomePage({Key? key}) : super(key: key);

  final _controller = TextEditingController();
  final currentEntries = entriesInCategory();

  void _addTodoEntry(AppDatabase database, Category? currentCategory) {
    if (_controller.text.isNotEmpty) {
      // We write the entry here. Notice how we don't have to call setState()
      // or anything - drift will take care of updating the list automatically.

      database.todoEntries.insertOne(TodoEntriesCompanion.insert(
        description: _controller.text,
        category: Value(currentCategory?.id),
      ));

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.provider.use;
    final category = activeCategory.use;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drift Todo list'),
        actions: [
          const BackupIcon(),
          IconButton(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        ],
      ),
      drawer: CategoriesDrawer(),
      body: ComputedBuilder(
        builder: (ctx) {
          try {
            final entries = currentEntries.use;
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return TodoCard(entries[index].entry);
              },
            );
          } on NoValueException {
            return const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          } catch (e, s) {
            debugPrintStack(label: e.toString(), stackTrace: s);
            return const Text('An error has occured');
          }
        },
      ),
      bottomSheet: Material(
        elevation: 12,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('What needs to be done?'),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _addTodoEntry(db, category),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () => _addTodoEntry(db, category),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
