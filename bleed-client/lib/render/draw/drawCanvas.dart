import 'dart:math';

import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CommonSettings.dart';
import 'package:bleed_client/common/ItemType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/constants/colors/white.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/cube/scene.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/isometric/utilities.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:bleed_client/render/mappers/loop.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/math.dart';
import 'package:lemon_math/opposite.dart';

const animationFrameRate = 7; // frames per change;

final Scene scene = Scene();

void drawCrates() {
  for(Vector2 crate in game.crates) {
    engine.draw.circle(crate.x, crate.y, 30, colours.red);
    draw(dst: crate, src: atlas.items.crate);
  }
}

void draw({required Vector2 dst, required Vector2 src, double size = 64, double scale = 1}){
  engine.actions.mapDst(x: dst.x -size / 2, y: dst.y - -size / 2, scale: scale);
  engine.actions.mapSrc(x: src.x, y: src.y, width: size, height: size);
  engine.actions.renderAtlas();
}

void drawItems() {
  for (int i = 0; i < game.itemsTotal; i++){
    drawItem(game.items[i]);
  }
}

void drawItem(Item item) {
  final _anchor = 32;

  if (!itemAtlas.containsKey(item.type)) return;

  engine.draw.drawCircleOutline(radius: commonSettings.itemRadius, x: item.x, y: item.y, color: white);
  srcLoop(
      atlas: itemAtlas[item.type]!,
      direction: Direction.Down,
      frame: core.state.timeline.frame,
      framesPerDirection: 8);
  engine.actions.mapDst(x: item.x - _anchor, y: item.y - _anchor,);
  engine.actions.renderAtlas();
}

void drawRoyalPerimeter() {
  engine.draw.drawCircleOutline(sides: 50, radius: game.royal.radius, x: game.royal.mapCenter.x, y: game.royal.mapCenter.y, color: Colors.red);
}

void drawEffects() {
  for (Effect effect in game.effects) {
    if (!effect.enabled) continue;
    if (effect.duration++ > effect.maxDuration) {
      effect.enabled = false;
      break;
    }

    if (effect.type == EffectType.FreezeCircle) {
      double p = effect.duration / effect.maxDuration;
      double maxRadius = 75;
      engine.draw.drawCircleOutline(
          sides: 16,
          radius: maxRadius * p,
          x: effect.x,
          y: effect.y,
          color: colours.blue
      );
    }
  }
}

void drawMouseAim2() {
  // if (game.player.characterType.value == CharacterType.Swordsman){
  engine.actions.setPaintColorWhite();
    double angle = getAngleBetweenMouseAndPlayer();
    double mouseDistance = getDistanceBetweenMouseAndPlayer();
    double d = min(mouseDistance, modules.game.state.player.attackRange);
    double vX = adjacent(angle, d);
    double vY = opposite(angle, d);
    drawLine(modules.game.state.player.x, modules.game.state.player.y, modules.game.state.player.x + vX, modules.game.state.player.y + vY);
  // }
}

void drawAbility() {
  if (modules.game.state.player.ability.value == AbilityType.None) {
    engine.draw.drawCircleOutline(
        sides: 24,
        radius: modules.game.state.player.attackRange,
        x: modules.game.state.player.x,
        y: modules.game.state.player.y,
        color: Colors.white24);
    return;
  }

  drawMouseAim2();

  engine.draw.drawCircleOutline(
      sides: 24,
      radius: modules.game.state.player.abilityRange,
      x: modules.game.state.player.x,
      y: modules.game.state.player.y,
      color: Colors.white);

  if (modules.game.state.player.abilityRadius != 0){
    engine.draw.drawCircleOutline(
        sides: 12,
        radius: modules.game.state.player.abilityRadius,
        x: mouseWorldX,
        y: mouseWorldY,
        color: Colors.white);
  }
}

void drawDebugCharacters() {
  for (int i = 0; i < game.totalHumans; i++) {
    engine.draw.circle(game.humans[i].x, game.humans[i].y, 10, Colors.white24);
  }
  for (int i = 0; i < game.totalNpcs; i++) {
    engine.draw.circle(game.interactableNpcs[i].x, game.interactableNpcs[i].y, 10,
        Colors.white24);
  }
}

void drawDebugEnvironmentObjects() {
  engine.state.paint.color = Colors.red;
  for (EnvironmentObject env in modules.isometric.state.environmentObjects) {
    drawLine(env.left, env.top, env.right, env.top); // top left to top right
    drawLine(
        env.right, env.top, env.right, env.bottom); // top left to bottom right
    drawLine(env.right, env.bottom, env.left, env.bottom);
    drawLine(env.left, env.top, env.left, env.bottom);
  }
  for (EnvironmentObject env in modules.isometric.state.environmentObjects) {
    engine.draw.circle(env.x, env.y, env.radius, Colors.blue);
  }
}



int compareParticles(Particle a, Particle b) {
  if (!a.active) {
    return 1;
  }
  if (!b.active) {
    return -1;
  }
  if (a.type == ParticleType.Blood) return -1;
  if (b.type == ParticleType.Blood) return 1;

  return a.y > b.y ? 1 : -1;
}

void sortParticles() {
  insertionSort(
      list: isometric.state.particles,
      compare: compareParticles,
      start: 0,
      end: isometric.state.particles.length);
}

bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
  if (environmentObject.top > engine.state.screen.bottom) return false;
  if (environmentObject.right < engine.state.screen.left) return false;
  if (environmentObject.left > engine.state.screen.right) return false;
  if (environmentObject.bottom < engine.state.screen.top) return false;
  return true;
}

void drawEnvironmentObject(EnvironmentObject env) {
  if (!environmentObjectOnScreenScreen(env)) return;

  final shade = isometric.properties.getShade(env.row, env.column);
  if (shade == Shade_PitchBlack) return;

  mapEnvironmentObjectToSrc(env);
  engine.actions.mapDst(x: env.dst[2], y: env.dst[3]);
  engine.actions.renderAtlas();
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

  double scope = mapWeaponAimLength(modules.game.state.player.weaponType.value);
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
};