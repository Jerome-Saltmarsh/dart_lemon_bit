import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/CollectableType.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/functions/insertionSort.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectToSrc.dart';
import 'package:bleed_client/render/constants/charWidth.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawBullets.dart';
import 'package:bleed_client/render/draw/drawCharacter.dart';
import 'package:bleed_client/render/draw/drawPlayerText.dart';
import 'package:bleed_client/render/enums/CharacterType.dart';
import 'package:bleed_client/render/functions/applyDynamicShadeToTileSrc.dart';
import 'package:bleed_client/render/functions/applyLightingToCharacters.dart';
import 'package:bleed_client/render/functions/emitLight.dart';
import 'package:bleed_client/render/functions/resetDynamicShadesToBakeMap.dart';
import 'package:bleed_client/render/state/dynamicShading.dart';
import 'package:bleed_client/render/state/floatingText.dart';
import 'package:bleed_client/state/game.dart';
import 'package:bleed_client/utils.dart';
import 'package:bleed_client/watches/ambientLight.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';
import 'package:lemon_engine/queries/on_screen.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/render/draw_text.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_engine/state/screen.dart';
import 'package:lemon_math/adjacent.dart';
import 'package:lemon_math/angle_between.dart';
import 'package:lemon_math/diff.dart';
import 'package:lemon_math/distance_between.dart';
import 'package:lemon_math/opposite.dart';

import '../../draw.dart';
import '../../state.dart';
import 'drawGrenade.dart';
import 'drawInteractableNpcs.dart';
import 'drawParticle.dart';

final double _nameRadius = 100;
int _flameIndex = 0;

bool get dayTime => ambient.index == Shade.Bright.index;
const animationFrameRate = 7; // frames per change;

void renderCanvasPlay() {
  if (frameRateValue++ % animationFrameRate == 0) {
    drawFrame++;
    _flameIndex = (_flameIndex + 1) % 4;
  }

  if (!dayTime) {
    resetDynamicShadesToBakeMap();
    // emitMouseLight();
    applyCharacterLightEmission(game.humans);
    applyProjectileLighting();
    applyNpcLightEmission(game.interactableNpcs);
  }

  // if (ambient.isLighterThan(Shade.PitchBlack)) {
  //   for (EnvironmentObject env in game.environmentObjects) {
  //     if (env.type != ObjectType.Tree01) continue;
  //     Shade shade = getShade(env.row, env.column);
  //     if (shade.index < 4){
  //       Shade darker = shades[shade.index + 1];
  //       dynamicShading[env.row][env.column] = darker;
  //     }
  //   }
  // }

  applyDynamicShadeToTileSrc();
  drawTiles();

  drawProjectiles(game.projectiles);
  drawBulletHoles(game.bulletHoles);
  _drawGrenades(game.grenades);
  drawSprites();

  if (game.settings.compilePaths) {
    drawDebugEnvironmentObjects();
    drawPaths();
    drawDebugNpcs(game.npcDebug);
  }

  _drawFloatingTexts();
  _drawPlayerNames();
  drawPlayerText();
  _drawMouseAim(); // TODO Expensive
}

void emitMouseLight() {
  if (mouseAvailable) {
    double distanceX =
        distanceBetween(playerX, playerY, mouseWorldX, mouseWorldY);
    double maxDistance = 80;

    if (distanceX < maxDistance) {
      emitLightHigh(dynamicShading, mouseWorldX, mouseWorldY);
    } else {
      double an = angleBetween(playerX, playerY, mouseWorldX, mouseWorldY);
      double x = adjacent(an, maxDistance);
      double y = opposite(an, maxDistance);
      emitLightHigh(dynamicShading, playerX + x, playerY + y);
    }
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
      emitLightHigh(dynamicShading, projectile.x, projectile.y);
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
              drawCharacter(game.humans[indexHuman], CharacterType.Human);
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
        drawCharacter(game.zombies[indexZombie], CharacterType.Zombie);
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
    env.dst,
    mapEnvironmentObjectToSrc(env),
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

void _drawMouseAim() {
  // if (game.playerWeapon.value == Weapon.HandGun) return;
  // if (game.playerWeapon.value == Weapon.Shotgun) return;
  if (!mouseAvailable) return;
  if (!playerReady) return;
  // Character _player = getPlayer;
  // if (_player == null) return;
  // if (player.equippedRounds.value == 0) return;
  paint.strokeWidth = 3;
  double angle =
      angleBetween(mouseWorldX, mouseWorldY, game.player.x, game.player.y);

  double mouseDistance =
      distanceBetween(mouseWorldX, mouseWorldY, playerX, playerY);

  double scope = mapWeaponAimLength(game.player.weapon.value);
  double d = min(mouseDistance, scope);

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
