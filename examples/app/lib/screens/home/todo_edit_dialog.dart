import 'package:computed/utils/streams.dart';
import 'package:computed_flutter/computed_flutter.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';

final _dateFormat = DateFormat.yMMMd();

class TodoEditDialog extends ComputedStatefulWidget {
  final TodoEntry entry;

  const TodoEditDialog({Key? key, required this.entry}) : super(key: key);

  @override
  State<TodoEditDialog> createState() => _TodoEditDialogState();
}

class _TodoEditDialogState extends State<TodoEditDialog> {
  final TextEditingController textController = TextEditingController();
  final _dueDate = ValueStream<DateTime?>();

  @override
  void initState() {
    textController.text = widget.entry.description;
    _dueDate.add(widget.entry.dueDate);
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
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
            final entry = widget.entry.copyWith(
              description: updatedContent.isNotEmpty ? updatedContent : null,
              dueDate: Value(dueDate),
            );

            db.todoEntries.replaceOne(entry);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
