import 'dart:ui';

import 'package:bleed_common/ItemType.dart';

// interface
Rect mapItemToRect(int itemType) {
  switch (itemType) {
    case ItemType.Health:
      return _health[0];
    case ItemType.Handgun:
      return _handgun[0];
    case ItemType.Shotgun:
      return _shotgun[0];
    default:
      throw Exception("Could not map $itemType to Rect");
  }
}

// private
const double _frameWidth = 47;
const double _frameHeight = 71;
final List<Rect> _handgun = _itemFrames([5]);
final List<Rect> _shotgun = _itemFrames([6]);
final List<Rect> _health = _itemFrames([8]);

List<Rect> _itemFrames(List<int> indexes) {
  return indexes.map(_itemFrame).toList();
}

Rect _itemFrame(int index) {
  return rect(index, _frameWidth, _frameHeight);
}

Rect rect(int index, double width, double height){
    return Rect.fromLTWH(width * (index - 1), 0, width, height);
}

