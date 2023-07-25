
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';

import 'isometric_provider.dart';

class IsometricApp extends StatefulWidget {
  @override
  State<IsometricApp> createState() => _IsometricAppState();
}

class _IsometricAppState extends State<IsometricApp> {

  @override
  Widget build(BuildContext context) {
    print('isometricApp.build()');
    return IsometricProvider(Isometric());
  }

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    print('isometricApp.initState()');
    print('isometricApp.initState(again)');
  }
}