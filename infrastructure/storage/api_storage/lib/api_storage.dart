// Storage contract layer — ports, serializers, key model, and failure codes.
// Import this package from feature/data layers to depend on the storage
// abstractions without coupling to any specific implementation.
export 'src/failure_codes/storage_failure_code.dart';
export 'src/models/storage_key.dart';
export 'src/ports/base/read_write_storage.dart';
export 'src/ports/key_value_storage.dart';
export 'src/ports/secure_storage.dart';
export 'src/serializers/json_serializer.dart';
export 'src/serializers/storage_serializer.dart';
export 'src/stored_value/stored_value.dart';
