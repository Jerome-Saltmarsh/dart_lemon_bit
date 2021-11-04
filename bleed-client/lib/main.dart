import 'package:bleed_client/bleed.dart';
import 'package:bleed_client/engine/GameWidget.dart';
import 'package:bleed_client/init.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:flutter/material.dart';

void main() {
  initBleed();
  runApp(GameWidget(
    init: init,
    title: "BLEED",
    buildUI: buildGameUI,
  ));
}

