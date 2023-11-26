import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runZonedGuarded(() async {
    runApp(modules.core.build.gameStream());
  }, (error, stackTrace){
        print("Unhandled Exception Caught");
        print(error);
        print(stackTrace);
  });
}
