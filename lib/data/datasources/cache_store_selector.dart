// Web = default, IO (Android/iOS/Desktop) override
export 'cache_store_web.dart' if (dart.library.io) 'cache_store_io.dart';
