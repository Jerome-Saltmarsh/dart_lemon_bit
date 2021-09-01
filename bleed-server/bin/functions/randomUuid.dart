import 'package:uuid/uuid.dart';

final Uuid _uuidGenerator = Uuid();

String randomUuid() => _uuidGenerator.v4();