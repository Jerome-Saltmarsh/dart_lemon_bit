import 'package:flutter/material.dart';

import 'gamestream/isometric/isometric.dart';
import 'ui/isomeric_app.dart';

void main() {
  print('main()');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IsometricApp(Isometric()));
}

