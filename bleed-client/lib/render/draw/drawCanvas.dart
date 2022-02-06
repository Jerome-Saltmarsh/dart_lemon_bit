import 'dart:math';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/opposite.dart';

bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
  if (environmentObject.top > engine.state.screen.bottom) return false;
  if (environmentObject.right < engine.state.screen.left) return false;
  if (environmentObject.left > engine.state.screen.right) return false;
  if (environmentObject.bottom < engine.state.screen.top) return false;
  return true;
}

double mapWeaponAimLength(WeaponType weapon) {
  switch (weapon) {
    case WeaponType.Unarmed:
      return 20;
    case WeaponType.HandGun:
      return 20;
    case WeaponType.Shotgun:
      return 25;
    case WeaponType.SniperRifle:
      return 150;
    case WeaponType.AssaultRifle:
      return 50;
    default:
      return 10;
  }
}

double getAngleBetweenMouseAndPlayer(){
  return angleBetween(modules.game.state.player.x, modules.game.state.player.y, mouseWorldX, mouseWorldY);
}

double getDistanceBetweenMouseAndPlayer(){
  return distanceBetween(mouseWorldX, mouseWorldY, modules.game.state.player.x, modules.game.state.player.y);
}

void _drawMouseAim() {
  if (modules.game.state.player.dead) return;

  engine.state.paint.strokeWidth = 3;
  double angle =
      angleBetween(mouseWorldX, mouseWorldY, modules.game.state.player.x, modules.game.state.player.y);

  double mouseDistance =
      distanceBetween(mouseWorldX, mouseWorldY, modules.game.state.player.x, modules.game.state.player.y);

  double scope = mapWeaponAimLength(modules.game.state.soldier.weaponType.value);
  double d = min(mouseDistance, scope);

  double vX = adjacent(angle, d);
  double vY = opposite(angle, d);
  Offset mouseOffset = Offset(mouseWorldX, mouseWorldY);
  Offset aimOffset = Offset(mouseWorldX + vX, mouseWorldY + vY);
  _drawLine(mouseOffset, aimOffset, Colors.transparent);
  engine.actions.setPaintColorWhite();
}

void _drawLine(Offset a, Offset b, Color color) {
  engine.state.paint.color = color;
  engine.state.canvas.drawLine(a, b, engine.state.paint);
}

final Map<ItemType, Vector2> itemAtlas = {
  ItemType.Handgun: atlas.items.handgun,
  ItemType.Shotgun: atlas.items.shotgun,
  ItemType.Armour: atlas.items.armour,
  ItemType.Health: atlas.items.health,
  ItemType.Orb_Emerald: atlas.items.emerald,
  ItemType.Orb_Ruby: atlas.items.orbRed,
  ItemType.Orb_Topaz: atlas.items.orbTopaz,
};