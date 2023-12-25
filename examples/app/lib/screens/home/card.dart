import 'package:computed_flutter/computed_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import 'todo_edit_dialog.dart';

final DateFormat _format = DateFormat.yMMMd();

/// Card that displays an entry and an icon button to delete that entry
class TodoCard extends ComputedWidget {
  final TodoEntry entry;

  TodoCard(this.entry) : super(key: ObjectKey(entry.id));

  @override
  Widget build(BuildContext context) {
    final dueDate = entry.dueDate;
    final db = AppDatabase.provider.use;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.description),
                  if (dueDate != null)
                    Text(
                      _format.format(dueDate),
                      style: const TextStyle(fontSize: 12),
                    )
                  else
                    const Text(
                      'No due date set',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.blue,
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => TodoEditDialog(entry: entry),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                // We delete the entry here. Again, notice how we don't have to
                // call setState() or inform the parent widget. Drift will take
                // care of updating the underlying data automatically
                db.todoEntries.deleteOne(entry);
              },
            )
          ],
        ),
      ),
    );
  }
}
