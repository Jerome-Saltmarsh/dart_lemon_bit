



import 'package:flutter/material.dart';
import 'package:gamestream_flutter/packages/common/src/amulet/amulet_element.dart';

Color getAmuletElementColor(AmuletElement amuletElement) => const {
  AmuletElement.fire: Colors.red,
  AmuletElement.water: Colors.blue,
  AmuletElement.air: Colors.greenAccent,
  AmuletElement.earth: Colors.brown,
}[amuletElement] ?? (throw Exception('mapElementToColor($amuletElement)'));