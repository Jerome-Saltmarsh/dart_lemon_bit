import 'package:uuid/uuid.dart';

mixin Entity {
  final String uuid = _uuid.v1();
}

final Uuid _uuid = Uuid();
