
import 'dart:ui';

import 'package:bleed_client/common/Tile.dart';

import '../rects.dart';

// interface
Rect mapTileToRect(Tile tile) {
  switch (tile) {
    case Tile.Concrete:
      return _concrete;
    case Tile.Grass:
      return _grass;
    case Tile.Fortress:
      return _playerSpawn;
    case Tile.PlayerSpawn:
      return _playerSpawn;
    case Tile.ZombieSpawn:
      return _zombieSpawn;
    case Tile.RandomItemSpawn:
      return _concrete;
    case Tile.Block:
      return _block;
    case Tile.Crate:
      return _crate;
  }
  throw Exception("could not find rect for tile $tile");
}

// abstraction
Rect _grass = _frame(1);
Rect _block = _frame(2);
Rect _concrete = _frame(3);
Rect _zombieSpawn = _frame(4);
Rect _playerSpawn = _frame(5);
Rect _crate = _frame(6);

Rect _frame(int index) {
  return Rect.fromLTWH((index - 1) * tileCanvasWidth.toDouble(), 0.0, tileCanvasWidth.toDouble(), tileCanvasHeight.toDouble());
}