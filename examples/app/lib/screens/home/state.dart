import 'package:computed/utils/streams.dart';
import 'package:computed_flutter/computed_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';

final activeCategory = ValueStream<Category?>.seeded(null);

Computed<List<TodoEntryWithCategory>> entriesInCategory(WidgetRef ref) {
  final database = ref.read(AppDatabase.provider);

  final activeCategoryId = $(() => activeCategory.use?.id);

  final reactiveQuery =
      activeCategoryId.asStream.map((id) => database.entriesInCategory(id));

  return $(() => reactiveQuery.use.use);
}
