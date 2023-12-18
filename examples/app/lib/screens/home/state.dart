import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';

final activeCategory = StateProvider<Category?>((_) => null);

Stream<List<TodoEntryWithCategory>> entriesInCategory(WidgetRef ref) {
  final database = ref.read(AppDatabase.provider);
  final current = ref.watch(activeCategory)?.id;

  return database.entriesInCategory(current);
}
