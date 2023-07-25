import 'package:flutter/material.dart';
import 'package:gamestream_flutter/ui/isomeric_app.dart';

import 'gamestream/isometric/isometric.dart';
import 'ui/isometric_provider.dart';

void main() {
  print('main()');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(IsometricProvider(Isometric()));
  // runApp(IsometricApp());

}

