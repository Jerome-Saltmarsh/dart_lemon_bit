import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/CollectableType.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/functions/applyLightingToEnvironmentObjects.dart';
import 'package:bleed_client/functions/calculateTileSrcRects.dart';
import 'package:bleed_client/functions/insertionSort.dart';
import 'package:bleed_client/mappers/mapItemToRSTransform.dart';
import 'package:bleed_client/mappers/mapItemToRect.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/render/draw/drawPlayerText.dart';
import 'package:bleed_client/render/drawCharacterMan.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:bleed_client/render/drawInteractableNpcs.dart';
import 'package:bleed_client/render/functions/applyLightBright.dart';
import 'package:bleed_client/render/functions/applyLightingToCharacters.dart';
import 'package:bleed_client/render/functions/drawBullets.dart';
import 'package:bleed_client/render/functions/drawDebugBox.dart';
import 'package:bleed_client/render/functions/drawRawAtlas.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/render/state/floatingText.dart';
import 'package:bleed_client/render/state/items.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/watches/ambientLight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/queries/on_screen.dart';
import 'package:lemon_engine/render/draw_atlas.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/render/draw_image.dart';
import 'package:lemon_engine/render/draw_text.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/opposite.dart';

import '../draw.dart';
import '../images.dart';
import '../state.dart';
import 'drawGrenade.dart';
import 'drawParticle.dart';

final double _nameRadius = 100;
int _flameIndex = 0;
int _flameRenderIndex = 0;
bool get dayTime => ambient.index == Shade.Bright.index;
const animationFrameRate = 7; // frames per change;

void renderCanvasPlay() {

  if (frameRateValue++ % animationFrameRate == 0) {
    drawFrame++;
    _flameIndex = (_flameIndex + 1) % 4;
    _flameRenderIndex = _flameIndex + 1;
  }

  if (!dayTime) {
    resetDynamicShadesToBakeMap();
    applyCharacterLightEmission(game.humans);
    applyProjectileLighting();
    applyNpcLightEmission(game.interactableNpcs);
    calculateTileSrcRects();
    applyLightingToEnvironmentObjects();
    _updateTorchFrames();
  }

  drawTiles();
  drawProjectiles(game.projectiles);
  drawBulletHoles(game.bulletHoles);
  _drawGrenades(game.grenades);
  _renderItems();
  _drawSprites();

  if (settings.compilePaths) {
    drawDebugEnvironmentObjects();
    drawPaths();
    drawDebugNpcs(game.npcDebug);
  }

  _drawFloatingTexts();
  _drawPlayerNames();
  drawPlayerText();
  _drawMouseAim(); // TODO Expensive
}

void drawDebugEnvironmentObjects() {
  paint.color = Colors.red;
  for(EnvironmentObject env in game.environmentObjects){
    drawLine(env.left, env.top, env.right, env.top); // top left to top right
    drawLine(env.right, env.top, env.right, env.bottom); // top left to bottom right
    drawLine(env.right, env.bottom, env.left, env.bottom);
    drawLine(env.left, env.top, env.left, env.bottom);
  }
  for(EnvironmentObject env in game.environmentObjects){
    drawCircle(env.x, env.y, env.radius, Colors.blue);
  }
}

void applyProjectileLighting() {
  for (int i = 0; i < game.totalProjectiles; i++) {
    Projectile projectile = game.projectiles[i];
    if (projectile.type == ProjectileType.Fireball) {
      applyLightBrightVerySmall(dynamicShading, projectile.x, projectile.y);
    }
  }
}

void _updateTorchFrames() {
  for(EnvironmentObject torch in game.torches){
    setSrcIndex(torch, _flameRenderIndex);
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
  return a.y > b.y ? 1 : -1;
}

void _sortParticles() {
  insertionSort(
      list: game.particles,
      compare: compareParticles,
      start: 0,
      end: settings.maxParticles);
}

int getTotalActiveParticles() {
  int totalParticles = 0;
  for (int i = 0; i < settings.maxParticles; i++) {
    if (game.particles[i].active) {
      totalParticles++;
    }
  }
  return totalParticles;
}

void _drawSprites() {
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

  for (EnvironmentObject environmentObject in game.backgroundObjects) {
    drawEnvironmentObject(environmentObject);
  }

  bool zombiesRemaining = indexZombie < game.totalZombies;
  bool humansRemaining = indexHuman < game.totalHumans;
  bool npcsRemaining = indexHuman < game.totalNpcs;
  bool environmentRemaining = indexEnv < totalEnvironment;
  bool particlesRemaining = indexParticle < totalParticles;

  while (true) {
    humansRemaining = indexHuman < game.totalHumans;
    environmentRemaining = indexEnv < totalEnvironment;
    particlesRemaining = indexParticle < totalParticles;
    zombiesRemaining = indexZombie < game.totalZombies;
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
        if (!particlesRemaining || humanY < game.particles[indexParticle].y) {
          if (!zombiesRemaining || humanY < game.zombies[indexZombie].y) {
            if (!npcsRemaining || humanY < game.interactableNpcs[indexNpc].y) {
              drawCharacterMan(game.humans[indexHuman]);
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

      if (!particlesRemaining || env.y < game.particles[indexParticle].y) {
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
        drawCharacterZombie(game.zombies[indexZombie]);
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

void drawEnvironmentObject(EnvironmentObject environmentObject) {
  if (!environmentObjectOnScreenScreen(environmentObject)) return;
  globalCanvas.drawRawAtlas(environmentObject.image, environmentObject.dst, environmentObject.src, null, null, null, paint);
}

void _renderItems() {
  items.transforms.clear();
  items.rects.clear();
  for (int i = 0; i < game.totalItems; i++) {
    items.transforms.add(mapItemToRSTransform(game.items[i]));
    items.rects.add(mapItemToRect(game.items[i].type));
  }
  drawAtlas(images.items, items.transforms, items.rects);
}

void _drawPlayerNames() {
  for (int i = 0; i < game.totalHumans; i++) {
    Character player = game.humans[i];
    if (player.x == game.playerX) continue;
    if (diff(mouseWorldX, player.x) > _nameRadius) continue;
    if (diff(mouseWorldY, player.y) > _nameRadius) continue;

    drawText(player.name, player.x - charWidth * player.name.length, player.y);
  }
}

void _drawMouseAim() {
  if (!mouseAvailable) return;
  if (!playerReady) return;
  Character _player = getPlayer;
  if (_player == null) return;
  if (player.equippedRounds.value == 0) return;
  Weapon weapon = _player.weapon;
  if (weapon == Weapon.HandGun) return;
  if (weapon == Weapon.Shotgun) return;

  paint.strokeWidth = 3;
  double angle =
      angleBetween(mouseWorldX, mouseWorldY, game.playerX, game.playerY);

  double mouseDistance =
      distanceBetween(mouseWorldX, mouseWorldY, playerX, playerY);
  double d = min(mouseDistance, weapon == Weapon.SniperRifle ? 150 : 35);

  double vX = adjacent(angle, d);
  double vY = opposite(angle, d);
  Offset mouseOffset = Offset(mouseWorldX, mouseWorldY);
  Offset aimOffset = Offset(mouseWorldX + vX, mouseWorldY + vY);
  _drawLine(mouseOffset, aimOffset, Colors.white);
}

// TODO Optimize
void drawCollectable(CollectableType type, double x, double y) {}

void _drawLine(Offset a, Offset b, Color color) {
  paint.color = color;
  globalCanvas.drawLine(a, b, paint);
}

void _drawGrenades(List<double> grenades) {
  for (int i = 0; i < grenades.length; i += 3) {
    drawGrenade(grenades[i], grenades[i + 1], grenades[i + 2]);
  }
}
