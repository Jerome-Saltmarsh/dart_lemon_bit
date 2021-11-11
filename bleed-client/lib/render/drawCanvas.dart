import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/CollectableType.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/applyLightingToEnvironmentObjects.dart';
import 'package:bleed_client/functions/calculateTileSrcRects.dart';
import 'package:bleed_client/functions/insertionSort.dart';
import 'package:bleed_client/render/draw/drawPlayerText.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/state/environmentObjects.dart';
import 'package:bleed_client/mappers/mapItemToRSTransform.dart';
import 'package:bleed_client/mappers/mapItemToRect.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/render/draw/drawCrates.dart';
import 'package:bleed_client/render/drawCharacterMan.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:bleed_client/render/drawInteractableNpcs.dart';
import 'package:bleed_client/render/functions/applyLightingToCharacters.dart';
import 'package:bleed_client/render/functions/drawBullets.dart';
import 'package:bleed_client/render/state/floatingText.dart';
import 'package:bleed_client/render/state/items.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/variables/ambientLight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/queries/on_screen.dart';
import 'package:lemon_engine/render/draw_atlas.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/render/draw_image_rect.dart';
import 'package:lemon_engine/render/draw_text.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/screen.dart';

import '../draw.dart';
import '../images.dart';
import '../state.dart';
import 'drawGrenade.dart';
import 'drawParticle.dart';

final double _nameRadius = 100;
final Ring _healthRing = Ring(16);
int _flameIndex = 0;

void renderCanvasPlay() {
  _updateAnimations();
  resetDynamicShadesToBakeMap();
  applyCharacterLightEmission(game.humans);
  applyCharacterLightEmission(game.interactableNpcs);
  applyLightingToEnvironmentObjects();
  calculateTileSrcRects();
  drawTiles();
  _drawNpcBonusPointsCircles();
  // _drawPlayerHealthRing();
  drawBullets(game.bullets);
  drawBulletHoles(game.bulletHoles);
  _drawGrenades(game.grenades);
  _renderItems();
  drawCrates();
  _drawCollectables();
  _drawSprites();

  if (settings.compilePaths) {
    drawPaths();
    drawDebugNpcs(game.npcDebug);
  }

  _drawFloatingTexts();
  _drawPlayerNames();
  drawPlayerText();
  _drawMouseAim();
}

void _updateAnimations() {
  frameRateValue++;
  if (frameRateValue % 7 == 0) {
    drawFrame++;
    if (ambientLight != Shading.Bright) {
      _flameIndex = (_flameIndex + 1) % 4;
      images.torch = images.flames[_flameIndex];
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

  int totalEnvironment = environmentObjects.length;

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
          humanY < environmentObjects[indexEnv].y) {
        if (!particlesRemaining ||
            humanY < game.particles[indexParticle].y) {
          if (!zombiesRemaining ||
              humanY < game.zombies[indexZombie].y) {
            if (!npcsRemaining ||
                humanY < game.interactableNpcs[indexNpc].y) {
              drawCharacterMan(game.humans[indexHuman]);
              indexHuman++;
              continue;
            }
          }
        }
      }
    }

    if (environmentRemaining) {
      EnvironmentObject env = environmentObjects[indexEnv];

      if (env.dst.top > screen.bottom) return;

      if (!particlesRemaining ||
          env.y < game.particles[indexParticle].y) {
        if (!zombiesRemaining || env.y < game.zombies[indexZombie].y) {
          if (!npcsRemaining ||
              env.y < game.interactableNpcs[indexNpc].y) {
            drawEnvironmentObject(environmentObjects[indexEnv]);
            indexEnv++;
            continue;
          }
        }
      }
    }

    if (particlesRemaining) {
      Particle particle = game.particles[indexParticle];

      if (!zombiesRemaining ||
          particle.y < game.zombies[indexZombie].y) {
        if (!npcsRemaining ||
            particle.y < game.interactableNpcs[indexNpc].y) {
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

      if (!npcsRemaining ||
          zombie.y < game.interactableNpcs[indexNpc].y) {
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
  if (environmentObject.dst.top > screen.bottom) return false;
  if (environmentObject.dst.right < screen.left) return false;
  if (environmentObject.dst.left > screen.right) return false;
  if (environmentObject.dst.bottom < screen.top) return false;
  return true;
}

void drawEnvironmentObject(EnvironmentObject environmentObject) {
  if (!environmentObjectOnScreenScreen(environmentObject)) return;

  drawImageRect(environmentObject.image, environmentObject.src, environmentObject.dst);
}

void _drawNpcBonusPointsCircles() {
  for (int i = 0; i < game.totalZombies; i++) {
    if (game.zombies[i].scoreMultiplier == "1") continue;
    Zombie npc = game.zombies[i];
    drawCircle(npc.x, npc.y, 10, colours.orange);
  }
}

void _drawPlayerHealthRing() {
  drawRing(_healthRing,
      percentage: player.health / player.maxHealth,
      color: healthColor,
      position: Offset(playerX, playerY));
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
  if (player.equippedRounds == 0) return;
  Weapon weapon = _player.weapon;
  if (weapon == Weapon.HandGun) return;
  if (weapon == Weapon.Shotgun) return;

  paint.strokeWidth = 3;
  double rot = radionsBetween(
      mouseWorldX, mouseWorldY, game.playerX, game.playerY);

  double mouseDistance = distance(mouseWorldX, mouseWorldY, playerX, playerY);
  double d = min(mouseDistance, weapon == Weapon.SniperRifle ? 150 : 35);
  double vX = velX(rot, d);
  double vY = velY(rot, d);
  Offset mouseOffset = Offset(mouseWorldX, mouseWorldY);
  Offset aimOffset = Offset(mouseWorldX + vX, mouseWorldY + vY);
  _drawLine(mouseOffset, aimOffset, Colors.white);
}

void _drawCollectables() {
  for (int i = 0; i < game.collectables.length; i += 3) {
    CollectableType type = CollectableType.values[game.collectables[i]];
    int x = game.collectables[i + 1];
    int y = game.collectables[i + 2];
    drawCollectable(type, x.toDouble(), y.toDouble());
  }
}

// TODO Optimize
void drawCollectable(CollectableType type, double x, double y) {}

void drawBlockSelected(Block block) {
  paint.strokeWidth = 3;
  _drawLine(block.top, block.right, Colors.red);
  _drawLine(block.right, block.bottom, Colors.red);
  _drawLine(block.bottom, block.left, Colors.red);
  _drawLine(block.left, block.top, Colors.red);
}

void _drawLine(Offset a, Offset b, Color color) {
  paint.color = color;
  globalCanvas.drawLine(a, b, paint);
}

Block createBlock(double topX, double topY, double rightX, double rightY,
    double bottomX, double bottomY, double leftX, double leftY) {
  // width *= 0.5;
  // length *= 0.5;
  //
  // Path path1 = Path();
  // path1.moveTo(x, y + length - height);
  // path1.lineTo(x - width, y - height);
  // path1.lineTo(x, y - length - height);
  // path1.lineTo(x + width, y - height);
  //
  // Path path2 = Path();
  // path2.moveTo(x, y + length);
  // path2.lineTo(x, y + length - height);
  // path2.lineTo(x - width, y - height);
  // path2.lineTo(x - width, y);
  //
  // Path path3 = Path();
  // path3.moveTo(x, y + length);
  // path3.lineTo(x, y + length - height);
  // path3.lineTo(x + width, y - height);
  // path3.lineTo(x + width, y);

  Offset top = Offset(topX, topY);
  Offset right = Offset(rightX, rightY);
  Offset bottom = Offset(bottomX, bottomY);
  Offset left = Offset(leftX, leftY);

  return Block(top, right, bottom, left);
}

void _drawGrenades(List<double> grenades) {
  for (int i = 0; i < grenades.length; i += 3) {
    drawGrenade(grenades[i], grenades[i + 1], grenades[i + 2]);
  }
}
