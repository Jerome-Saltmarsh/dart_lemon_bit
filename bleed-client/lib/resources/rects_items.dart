import 'dart:ui';

import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/state.dart';

// interface
Rect mapItemToRect(ItemType item) {
  switch (item) {
    case ItemType.Health:
      return _health[drawFrame % _healthFrames];
    case ItemType.Ammo:
      return _ammo[0];
    case ItemType.Grenade:
      return _grenade[0];
    case ItemType.Credits:
      return _credits[0];
    case ItemType.Assault_Rifle:
      return _assaultRifle[0];
    default:
      throw Exception("Could not map $item to Rect");
  }
}

// private
const double _frameWidth = 47;
const double _frameHeight = 71;
final List<Rect> _ammo = _itemFrames([5]);
final List<Rect> _grenade = _itemFrames([6]);
final List<Rect> _credits = _itemFrames([7]);
final List<Rect> _assaultRifle = _itemFrames([8]);
final List<Rect> _health = _itemFrames([9]);
final int _healthFrames = _health.length;

List<Rect> _itemFrames(List<int> indexes) {
  return indexes.map(_itemFrame).toList();
}

Rect _itemFrame(int index) {
  return rect(index, _frameWidth, _frameHeight);
}

