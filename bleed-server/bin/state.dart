import 'package:uuid/uuid.dart';

import 'enums.dart';

int frame = 0;
DateTime frameTime = DateTime.now();
Duration frameDuration = Duration();
int fps = 30;
final Uuid uuidGenerator = Uuid();

