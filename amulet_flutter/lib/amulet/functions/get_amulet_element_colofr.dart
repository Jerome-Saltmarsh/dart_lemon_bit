



import 'package:flutter/material.dart';
import 'package:amulet_engine/packages/common.dart';

Color getAmuletElementColor(AmuletElement amuletElement) => const {
  AmuletElement.fire: Colors.red,
  AmuletElement.water: Colors.blue,
  AmuletElement.electricity: Colors.yellow,
}[amuletElement] ?? (throw Exception('mapElementToColor($amuletElement)'));