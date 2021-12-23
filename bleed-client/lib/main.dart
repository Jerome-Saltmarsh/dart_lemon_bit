import 'package:bleed_client/core/buildBleed.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(buildBleed());
}
