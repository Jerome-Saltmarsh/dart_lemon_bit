import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/init.dart';
import 'package:flutter/material.dart';

void main() {
  initBleed();
  runApp(GameWidget(init: init, title: "BLEED",));
}

