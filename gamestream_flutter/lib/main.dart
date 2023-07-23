import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

import 'library.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IsometricProvider(gamestream));
}

