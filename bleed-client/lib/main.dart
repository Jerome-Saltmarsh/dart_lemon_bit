import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

import 'modules.dart';


void main() {
  setPathUrlStrategy();
  runApp(modules.core.build.gameStream());
}
