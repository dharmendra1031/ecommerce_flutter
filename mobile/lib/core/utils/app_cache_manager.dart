import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager {
  const AppCacheManager._();

  static const String _key = 'westoreImageCache';

  static final instance = CacheManager(
    Config(
      _key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: _key),
      fileService: HttpFileService(),
    ),
  );
}
