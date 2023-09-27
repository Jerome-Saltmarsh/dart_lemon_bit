import 'package:uuid/uuid.dart';

final _uuid = Uuid();

String generateUUID() => _uuid.v4();