import 'dart:io';

import 'package:app/database/connection/native.dart';
import 'package:app/database/database.dart';
import 'package:computed_flutter/computed_flutter.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class BackupIcon extends StatelessWidget {
  const BackupIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () =>
          showDialog(context: context, builder: (_) => const BackupDialog()),
      icon: const Icon(Icons.save),
      tooltip: 'Backup',
    );
  }
}

class BackupDialog extends ComputedWidget {
  const BackupDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.provider.use;
    return AlertDialog(
      title: const Text('Database backup'),
      content: const Text(
        'Here, you can save the database to a file or restore a created '
        'backup.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            createDatabaseBackup(db);
          },
          child: const Text('Save'),
        ),
        TextButton(
          onPressed: () async {
            await db.close();

            // Open the selected database file
            final backupFile = await FilePicker.platform.pickFiles();
            if (backupFile == null) return;
            final backupDb = sqlite3.open(backupFile.files.single.path!);

            // Vacuum it into a temporary location first to make sure it's working.
            final tempPath = await getTemporaryDirectory();
            final tempDb = p.join(tempPath.path, 'import.db');
            backupDb
              ..execute('VACUUM INTO ?', [tempDb])
              ..dispose();

            // Then replace the existing database file with it.
            final tempDbFile = File(tempDb);
            await tempDbFile.copy((await databaseFile).path);
            await tempDbFile.delete();

            // And now, re-open the database!
            AppDatabase.provider.add(AppDatabase());
          },
          child: const Text('Restore'),
        ),
      ],
    );
  }
}

Future<void> createDatabaseBackup(DatabaseConnectionUser database) async {
  final choosenDirectory = await FilePicker.platform.getDirectoryPath();
  if (choosenDirectory == null) return;

  final parent = Directory(choosenDirectory);
  final file = File(p.join(choosenDirectory, 'drift_example_backup.db'));

  // Make sure the directory of the file exists
  if (!await parent.exists()) {
    await parent.create(recursive: true);
  }
  // However, the file itself must not exist
  if (await file.exists()) {
    await file.delete();
  }

  await database.customStatement('VACUUM INTO ?', [file.absolute.path]);
}
