import 'package:computed/utils/streams.dart';
import 'package:computed_flutter/computed_flutter.dart';

import '../../database/database.dart';

final activeCategory = ValueStream<Category?>.seeded(null);

Computed<List<TodoEntryWithCategory>> entriesInCategory() {
  return Computed.async(() =>
          AppDatabase.provider.use.entriesInCategory(activeCategory.use?.id))
      .unwrap;
}
