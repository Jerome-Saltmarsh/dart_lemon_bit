import 'dart:ui';

import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/state.dart';

// interface
Rect mapItemToRect(ItemType item) {
  switch (item) {
    case ItemType.Health:
      return _rectsHealth[drawFrame % _healthFrames];
    case ItemType.Ammo:
      return _rectsAmmo[0];
    default:
      throw Exception("Could not map $item to Rect");
  }
}

// private
const double _frameWidth = 47;
const double _frameHeight = 71;

final List<Rect> _rectsHealth = _itemFrames([1, 1, 2, 2, 3, 3, 4, 4, 3, 3]);
final List<Rect> _rectsAmmo = _itemFrames([5]);
final int _healthFrames = _rectsHealth.length;

List<Rect> _itemFrames(List<int> indexes) {
  return indexes.map(_itemFrame).toList();
}

Rect _itemFrame(int index) {
  return rect(index, _frameWidth, _frameHeight);
}

