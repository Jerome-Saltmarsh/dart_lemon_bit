import 'package:flutter/material.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(modules.core.build.gameStream());
}
