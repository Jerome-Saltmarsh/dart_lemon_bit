import 'dart:math';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/Explosion.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Item.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/AbilityType.dart';
import 'package:bleed_client/common/CommonSettings.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/constants/colors/white.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/modules/core/render.dart';
import 'package:bleed_client/cube/scene.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/insertionSort.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/maps.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawBullets.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:bleed_client/render/draw/drawPlayerText.dart';
import 'package:bleed_client/render/functions/applyDynamicShadeToTileSrc.dart';
import 'package:bleed_client/render/functions/applyLightingToCharacters.dart';
import 'package:bleed_client/render/functions/emitLight.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/render/mappers/loop.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapSrc.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/render/state/floatingText.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/watches/ambientLight.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/queries/on_screen.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/render/draw_text.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_math/Vector2.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/opposite.dart';

import '../../draw.dart';
import 'drawInteractableNpcs.dart';
import 'drawParticle.dart';

final double _nameRadius = 100;

bool get dayTime => ambient.index == Shade.Bright.index;
const animationFrameRate = 7; // frames per change;

final Scene scene = Scene();

void renderGame(Canvas canvas, Size size) {

  if (game.type.value == GameType.CUBE3D){
    scene.render(canvas, size);
    return;
  }

  if (!dayTime) {
    resetDynamicShadesToBakeMap();
    applyCharacterLightEmission(game.humans);
    applyCharacterLightEmission(game.zombies);
    applyProjectileLighting();
    applyNpcLightEmission(game.interactableNpcs);

    for (Effect effect in game.effects) {
      if (!effect.enabled) continue;
      double p = effect.duration / effect.maxDuration;
      if (p < 0.33) {
        emitLightHigh(dynamicShading, effect.x, effect.y);
        break;
      }
      if (p < 0.66) {
        emitLightMedium(dynamicShading, effect.x, effect.y);
        break;
      }
      emitLightLow(dynamicShading, effect.x, effect.y);
    }
  }

  applyDynamicShadeToTileSrc();
  drawTiles();
  drawProjectiles(game.projectiles);
  drawBulletHoles(game.bulletHoles);



  if (game.player.isHuman){
    // drawCircle(game.player.w.x, attackTarget.y, 20, Colors.white24);
  } else {
    drawAbility();
    final Vector2 attackTarget = game.player.attackTarget;
    if (attackTarget.x != 0 && attackTarget.y != 0){
      drawCircle(attackTarget.x, attackTarget.y, 20, Colors.white24);
    }
  }


  setColorWhite();
  drawSprites();
  drawEffects();
  drawItems();
  // drawCrates();

  if (game.settings.compilePaths) {
    drawDebugEnvironmentObjects();
    drawPaths();
    drawDebugNpcs(game.npcDebug);
  }

  if (game.type.value == GameType.BATTLE_ROYAL){
    drawRoyalPerimeter();
  }

  _drawFloatingTexts();
  _drawPlayerNames();
  drawPlayerText();
  setColorWhite();
}

void drawCrates() {
  for(Vector2 crate in game.crates) {
    drawCircle(crate.x, crate.y, 30, colours.red);
    draw(dst: crate, src: atlas.items.crate);
  }
}

void draw({required Vector2 dst, required Vector2 src, double size = 64}){
  drawAtlas(dst: buildDst(dst, translateY: -size / 2, translateX: -size / 2), src: buildSrc(src));
}

void drawItems() {
  for (int i = 0; i < game.itemsTotal; i++){
    drawItem(game.items[i]);
  }
}

void drawItem(Item item) {
  drawCircleOutline(radius: commonSettings.itemRadius, x: item.x, y: item.y, color: white);
  drawAtlas(
      dst: buildDst(item, translateX: -32, translateY: -32),
      src: srcLoop(
          atlas: maps.itemAtlas[item.type]!,
          direction: Direction.Down,
          frame: timeline.frame,
          framesPerDirection: 8));
}

void drawRoyalPerimeter() {
  drawCircleOutline(sides: 50, radius: game.royal.radius, x: game.royal.mapCenter.x, y: game.royal.mapCenter.y, color: Colors.red);
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
      drawCircleOutline(
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
    setColorWhite();
    double angle = getAngleBetweenMouseAndPlayer();
    double mouseDistance = getDistanceBetweenMouseAndPlayer();
    double d = min(mouseDistance, game.player.attackRange);
    double vX = adjacent(angle, d);
    double vY = opposite(angle, d);
    drawLine(game.player.x, game.player.y, game.player.x + vX, game.player.y + vY);
  // }
}

void drawAbility() {
  if (game.player.ability.value == AbilityType.None) {
    drawCircleOutline(
        sides: 24,
        radius: game.player.attackRange,
        x: game.player.x,
        y: game.player.y,
        color: Colors.white24);
    return;
  }

  drawMouseAim2();

  drawCircleOutline(
      sides: 24,
      radius: game.player.abilityRange,
      x: game.player.x,
      y: game.player.y,
      color: Colors.white);

  if (game.player.abilityRadius != 0){
    if (mouseAvailable){
      drawCircleOutline(
          sides: 12,
          radius: game.player.abilityRadius,
          x: mouseWorldX,
          y: mouseWorldY,
          color: Colors.white);
    }
  }
}

void drawDebugCharacters() {
  for (int i = 0; i < game.totalHumans; i++) {
    drawCircle(game.humans[i].x, game.humans[i].y, 10, Colors.white24);
  }
  for (int i = 0; i < game.totalNpcs; i++) {
    drawCircle(game.interactableNpcs[i].x, game.interactableNpcs[i].y, 10,
        Colors.white24);
  }
}

void drawDebugEnvironmentObjects() {
  paint.color = Colors.red;
  for (EnvironmentObject env in game.environmentObjects) {
    drawLine(env.left, env.top, env.right, env.top); // top left to top right
    drawLine(
        env.right, env.top, env.right, env.bottom); // top left to bottom right
    drawLine(env.right, env.bottom, env.left, env.bottom);
    drawLine(env.left, env.top, env.left, env.bottom);
  }
  for (EnvironmentObject env in game.environmentObjects) {
    drawCircle(env.x, env.y, env.radius, Colors.blue);
  }
}

void applyProjectileLighting() {
  for (int i = 0; i < game.totalProjectiles; i++) {
    Projectile projectile = game.projectiles[i];
    if (projectile.type == ProjectileType.Fireball) {
      emitLightBrightSmall(dynamicShading, projectile.x, projectile.y);
    }
  }
}

void _drawFloatingTexts() {
  for (FloatingText floatingText in floatingText) {
    if (floatingText.duration == 0) continue;
    floatingText.duration--;
    floatingText.y -= 0.5;
    drawText(floatingText.value, floatingText.x, floatingText.y);
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

void _sortParticles() {
  insertionSort(
      list: game.particles,
      compare: compareParticles,
      start: 0,
      end: game.particles.length);
}

int getTotalActiveParticles() {
  int totalParticles = 0;
  for (int i = 0; i < game.particles.length; i++) {
    if (game.particles[i].active) {
      totalParticles++;
    }
  }
  return totalParticles;
}

void drawSprites() {
  setColorWhite();
  int indexHuman = 0;
  int indexEnv = 0;
  int indexParticle = 0;
  int indexZombie = 0;
  int indexNpc = 0;
  int totalParticles = getTotalActiveParticles();

  int totalEnvironment = game.environmentObjects.length;

  if (totalParticles > 0) {
    _sortParticles();
  }

  bool zombiesRemaining = indexZombie < game.totalZombies.value;
  bool humansRemaining = indexHuman < game.totalHumans;
  bool npcsRemaining = indexHuman < game.totalNpcs;
  bool environmentRemaining = indexEnv < totalEnvironment;
  bool particlesRemaining = indexParticle < totalParticles;

  while (true) {
    humansRemaining = indexHuman < game.totalHumans;
    environmentRemaining = indexEnv < totalEnvironment;
    particlesRemaining = indexParticle < totalParticles;
    zombiesRemaining = indexZombie < game.totalZombies.value;
    npcsRemaining = indexNpc < game.totalNpcs;

    if (!zombiesRemaining &&
        !humansRemaining &&
        !environmentRemaining &&
        !particlesRemaining &&
        !npcsRemaining) return;

    if (humansRemaining) {
      double humanY = game.humans[indexHuman].y;

      if (!environmentRemaining ||
          humanY < game.environmentObjects[indexEnv].y) {
        if (!particlesRemaining ||
            humanY < game.particles[indexParticle].y &&
                game.particles[indexParticle].type != ParticleType.Blood) {
          if (!zombiesRemaining || humanY < game.zombies[indexZombie].y) {
            if (!npcsRemaining || humanY < game.interactableNpcs[indexNpc].y) {
              drawCharacter(game.humans[indexHuman]);
              indexHuman++;
              continue;
            }
          }
        }
      }
    }

    if (environmentRemaining) {
      EnvironmentObject env = game.environmentObjects[indexEnv];

      if (env.top > screen.bottom) return;

      if (!particlesRemaining ||
          env.y < game.particles[indexParticle].y &&
              game.particles[indexParticle].type != ParticleType.Blood) {
        if (!zombiesRemaining || env.y < game.zombies[indexZombie].y) {
          if (!npcsRemaining || env.y < game.interactableNpcs[indexNpc].y) {
            drawEnvironmentObject(game.environmentObjects[indexEnv]);
            indexEnv++;
            continue;
          }
        }
      }
    }

    if (particlesRemaining) {
      Particle particle = game.particles[indexParticle];

      if (particle.type == ParticleType.Blood) {
        if (onScreen(particle.x, particle.y)) {
          drawParticle(particle);
        }
        indexParticle++;
        continue;
      }

      if (!zombiesRemaining || particle.y < game.zombies[indexZombie].y) {
        if (!npcsRemaining || particle.y < game.interactableNpcs[indexNpc].y) {
          if (onScreen(particle.x, particle.y)) {
            drawParticle(particle);
          }
          indexParticle++;
          continue;
        }
      }
    }

    if (zombiesRemaining) {
      Zombie zombie = game.zombies[indexZombie];

      if (!npcsRemaining || zombie.y < game.interactableNpcs[indexNpc].y) {
        drawCharacter(game.zombies[indexZombie]);
        indexZombie++;
        continue;
      }
    }

    drawInteractableNpc(game.interactableNpcs[indexNpc]);
    indexNpc++;
  }
}

bool environmentObjectOnScreenScreen(EnvironmentObject environmentObject) {
  if (environmentObject.top > screen.bottom) return false;
  if (environmentObject.right < screen.left) return false;
  if (environmentObject.left > screen.right) return false;
  if (environmentObject.bottom < screen.top) return false;
  return true;
}

void drawEnvironmentObject(EnvironmentObject env) {
  if (!environmentObjectOnScreenScreen(env)) return;
  drawAtlas(
    dst: env.dst,
    src: mapEnvironmentObjectToSrc(env),
  );
}

void _drawPlayerNames() {
  for (int i = 0; i < game.totalHumans; i++) {
    Character player = game.humans[i];
    if (player.x == game.player.x) continue;
    if (diff(mouseWorldX, player.x) > _nameRadius) continue;
    if (diff(mouseWorldY, player.y) > _nameRadius) continue;

    drawText(player.name, player.x - charWidth * player.name.length, player.y);
  }
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
  return angleBetween(game.player.x, game.player.y, mouseWorldX, mouseWorldY);
}

double getDistanceBetweenMouseAndPlayer(){
  return distanceBetween(mouseWorldX, mouseWorldY, game.player.x, game.player.y);
}

void _drawMouseAim() {
  if (!mouseAvailable) return;
  if (game.player.dead) return;

  paint.strokeWidth = 3;
  double angle =
      angleBetween(mouseWorldX, mouseWorldY, game.player.x, game.player.y);

  double mouseDistance =
      distanceBetween(mouseWorldX, mouseWorldY, game.player.x, game.player.y);

  double scope = mapWeaponAimLength(game.player.weaponType.value);
  double d = min(mouseDistance, scope);

  double vX = adjacent(angle, d);
  double vY = opposite(angle, d);
  Offset mouseOffset = Offset(mouseWorldX, mouseWorldY);
  Offset aimOffset = Offset(mouseWorldX + vX, mouseWorldY + vY);
  _drawLine(mouseOffset, aimOffset, Colors.transparent);
  setColorWhite();
}

void _drawLine(Offset a, Offset b, Color color) {
  paint.color = color;
  globalCanvas.drawLine(a, b, paint);
}

