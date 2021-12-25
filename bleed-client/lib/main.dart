import 'package:bleed_client/core/buildBleed.dart';
import 'package:flutter/material.dart';
import 'package:lemon_watch/watch.dart';
import 'package:url_strategy/url_strategy.dart';

Watch<Widget> activeWidget = Watch(buildBleed());

void main() {
  setPathUrlStrategy();
  runApp(activeWidget.value);
}
