import 'package:uuid/uuid.dart';

final Uuid _uuidGenerator = Uuid();

String generateUUID() {
  return _uuidGenerator.v4();
}