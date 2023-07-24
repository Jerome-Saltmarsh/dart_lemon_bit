
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

import 'isometric_provider.dart';

class IsometricApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('isometricApp.build()');
    WidgetsFlutterBinding.ensureInitialized();
    return IsometricProvider(Isometric());
  }
}