

import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/modules.dart';
import 'package:bleed_client/state/game.dart';

import '../../draw.dart';

class IsometricProperties {
  
  bool get dayTime => modules.isometric.state.ambient.value.index == Shade.Bright.index;

  Tile get tileAtMouse {
    if (mouseRow < 0) return Tile.Boundary;
    if (mouseColumn < 0) return Tile.Boundary;
    if (mouseRow >= game.totalRows) return Tile.Boundary;
    if (mouseColumn >= game.totalColumns) return Tile.Boundary;
    return game.tiles[mouseRow][mouseColumn];
  }
}