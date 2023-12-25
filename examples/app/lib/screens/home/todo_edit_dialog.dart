import 'package:computed/utils/streams.dart';
import 'package:computed_flutter/computed_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';

final _dateFormat = DateFormat.yMMMd();

class TodoEditDialog extends ComputedWidget {
  final TodoEntry entry;
  final textController = TextEditingController();
  late final ValueStream<DateTime?> _dueDate;

  TodoEditDialog({Key? key, required this.entry}) : super(key: key) {
    textController.text = entry.description;
    _dueDate = ValueStream<DateTime?>.seeded(entry.dueDate);
  }

  @override
  Widget build(BuildContext context) {
    var formattedDate = 'No date set';
    final dueDate = _dueDate.use;
    if (dueDate != null) {
      formattedDate = _dateFormat.format(dueDate);
    }
    final db = AppDatabase.provider.use;

    return AlertDialog(
      title: const Text('Edit entry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'What needs to be done?',
              helperText: 'Content of entry',
            ),
          ),
          Row(
            children: <Widget>[
              Text(formattedDate),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final now = DateTime.now();
                  final initialDate = dueDate ?? now;
                  final firstDate =
                      initialDate.isBefore(now) ? initialDate : now;

                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: firstDate,
                    lastDate: DateTime(3000),
                  );

                  if (selectedDate != null) _dueDate.add(selectedDate);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
              const TextStyle(color: Colors.black),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            final updatedContent = textController.text;
            final newEntry = entry.copyWith(
              description: updatedContent.isNotEmpty ? updatedContent : null,
              dueDate: Value(dueDate),
            );

            db.todoEntries.replaceOne(newEntry);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
