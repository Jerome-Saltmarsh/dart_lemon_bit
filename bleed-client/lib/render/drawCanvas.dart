import 'dart:math';
import 'dart:ui';

import 'package:bleed_client/classes/Block.dart';
import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/classes/EnvironmentObject.dart';
import 'package:bleed_client/classes/FloatingText.dart';
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/classes/Zombie.dart';
import 'package:bleed_client/common/CollectableType.dart';
import 'package:bleed_client/common/Tile.dart';
import 'package:bleed_client/common/Weapons.dart';
import 'package:bleed_client/common/classes/Vector2.dart';
import 'package:bleed_client/editor/editor.dart';
import 'package:bleed_client/engine/functions/drawCircle.dart';
import 'package:bleed_client/engine/functions/drawText.dart';
import 'package:bleed_client/engine/functions/onScreen.dart';
import 'package:bleed_client/engine/properties/mouseWorld.dart';
import 'package:bleed_client/engine/render/drawAtlas.dart';
import 'package:bleed_client/engine/render/drawImageRect.dart';
import 'package:bleed_client/engine/render/gameWidget.dart';
import 'package:bleed_client/engine/state/canvas.dart';
import 'package:bleed_client/engine/state/paint.dart';
import 'package:bleed_client/engine/state/screen.dart';
import 'package:bleed_client/enums/Shading.dart';
import 'package:bleed_client/functions/insertionSort.dart';
import 'package:bleed_client/mappers/mapCrateToRSTransform.dart';
import 'package:bleed_client/mappers/mapEnvironmentObjectTypeToImage.dart';
import 'package:bleed_client/mappers/mapItemToRSTransform.dart';
import 'package:bleed_client/mappers/mapItemToRect.dart';
import 'package:bleed_client/mappers/mapShadeToTileImage.dart';
import 'package:bleed_client/mappers/mapTileToRect.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/render/drawCharacterMan.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:bleed_client/state/colours.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../draw.dart';
import '../images.dart';
import '../state.dart';
import 'drawBullet.dart';
import 'drawGrenade.dart';
import 'drawParticle.dart';

final double _anchorX = 50;
final double _anchorY = 80;
final double _nameRadius = 100;
final double charWidth = 4.5;
final Ring _healthRing = Ring(16);
int _flameIndex = 0;

void drawCanvas(Canvas canvass, Size _size) {
  if (editMode) {
    drawTiles();
    _drawEnvironmentObjects();
    _drawCratesEditor();
    drawEditor();
    return;
  }

  _drawCompiledGame();
}

void calculateTileSrcRects(){
  int i = 0;
  for (int row = 0; row < compiledGame.totalRows; row++) {
    for (int column = 0; column < compiledGame.totalColumns; column++) {
      // if (isBlock(compiledGame.tiles[row][column])) continue;
      // double x = render.tilesRstTransforms[i + 2];
      // double y = render.tilesRstTransforms[i + 3];
      // if (!onScreen(x, y)) continue;
      if (column >= compiledGame.tiles.length){
        print('invalid');
      }
      if (row >= compiledGame.tiles[0].length){
        print('invalid');
      }

      Tile tile = compiledGame.tiles[column][row];
      Rect rect = mapTileToSrcRect(tile);

      if (i >= render.tilesRects.length){
        print("invalid");
        return;
      }

      render.tilesRects[i] = rect.left;

      if (i + 2 >= render.tilesRects.length){
        print("invalid");
        return;
      }
      render.tilesRects[i + 2] = rect.right;
      i += 4;
    }
  }
  // for(int i = 0; i < render.tilesRects.length; i += 4){
  //     double srcLeft = render.tilesRects[i];
  //     double srcTop = 0;
  //     double srcRight = render.tilesRects[i + 2];
  //     double srcBottom = 48;
  //     double x = render.tilesRstTransforms[i + 2];
  //     double y = render.tilesRstTransforms[i + 3];
  // }
}

void setTileType(int index, double frame){
  int i = index * 4;
  render.tilesRects[i] = 48 * frame;
  render.tilesRects[i + 1] = 0;
  render.tilesRects[i + 2] = 48 * (frame + 1);
  render.tilesRects[i + 3] = 72;
}

void _drawCompiledGame() {
  if (!connected) return;
  if (compiledGame.gameId < 0) return;

  frameRateValue++;
  if (frameRateValue % frameRate == 0) {
    drawFrame++;
    _flameIndex = (_flameIndex + 1) % 3;

    for (EnvironmentObject torch in compiledGame.torches) {
      torch.image = images.flames[_flameIndex];
    }
  }
  // drawDynamicTiles();
  // double i = randomBetween(0, 6);
  //
  // render.tilesRects[0] = 48 * i;
  // render.tilesRects[1] = 0;
  // render.tilesRects[2] = 48 * (i + 1);
  // render.tilesRects[3] = 72;

  calculateTileSrcRects();
  drawTiles();
  _drawNpcBonusPointsCircles();
  // _drawPlayerHealthRing();
  _drawBullets(compiledGame.bullets);
  drawBulletHoles(compiledGame.bulletHoles);
  _drawGrenades(compiledGame.grenades);
  _renderItems();
  _drawCrates();
  drawCharacters();
  _drawCollectables();
  _drawSprites();

  if (settings.compilePaths) {
    drawPaths();
    drawDebugNpcs(compiledGame.npcDebug);
  }

  _drawFloatingTexts();
  _drawPlayerNames();
  _writePlayerText();
  _drawMouseAim();
}

void drawDynamicTiles() {
  int rows = compiledGame.tiles.length;
  int columns = compiledGame.tiles[0].length;

  for (int row = 0; row < rows; row++) {
    for (int column = 0; column < columns; column++) {
      drawDynamicTile(row, column);
    }
  }
}

double _light = 100;
double _medium = 250;
double _dark = 400;

Shading getShadingAt(double x, double y) {
  Shading shading = Shading.Dark;

  for (Character player in compiledGame.humans) {
    double xDiff = diff(x, player.x);
    if (xDiff > _dark) continue;
    double yDiff = diff(y, player.y);
    if (yDiff > _dark) continue;
    double total = xDiff + yDiff;

    if (total < _light) {
      return Shading.Bright;
    }
    if (total < _medium) {
      shading = Shading.Medium;
    }
  }

  // for (Vector2 light in compiledGame.lights) {
  //   double xDiff = diff(x, light.x);
  //   if (xDiff > _dark) continue;
  //   double yDiff = diff(y, light.y);
  //   if (yDiff > _dark) continue;
  //
  //   double total = xDiff + yDiff;
  //
  //   if (total < _light) {
  //     return Shading.Bright;
  //   }
  //   if (total < _medium) {
  //     shading = Shading.Medium;
  //   }
  // }

  return shading;
}

void drawDynamicTile(int row, int column) {
  double x = getTileWorldX(row, column);
  double y = getTileWorldY(row, column);
  if (!onScreen(x, y)) return;

  Shading shading = getShadingAt(x, y);
  // Shading shading = Shading.Bright;

  Tile tile = compiledGame.tiles[row][column];
  if (isBlock(tile)) return;

  Rect dst = Rect.fromLTWH(x - 24, y - 36, 48, 72);
  Rect src = mapTileToSrcRect(tile);
  drawImageRect(mapShadeToImage(shading), src, dst);
}

// Rect mapTileToDstRect(int row, int column) {
//   double x = getTileWorldX(row, column);
//   double y = getTileWorldY(row, column);
//   return Rect.fromLTWH(x - 24, y - 24, 48, 48);
// }

void _drawFloatingTexts() {
  for (FloatingText floatingText in render.floatingText) {
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
      list: compiledGame.particles,
      compare: compareParticles,
      start: 0,
      end: settings.maxParticles);
}

int getTotalActiveParticles() {
  int totalParticles = 0;
  for (int i = 0; i < settings.maxParticles; i++) {
    if (compiledGame.particles[i].active) {
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
  int totalParticles = getTotalActiveParticles();

  int totalEnvironment = compiledGame.environmentObjects.length;

  if (totalParticles > 0) {
    _sortParticles();
  }

  for (EnvironmentObject environmentObject in compiledGame.backgroundObjects) {
    drawEnvironmentObject(environmentObject);
  }

  bool zombiesRemaining = indexZombie < compiledGame.totalZombies;
  bool humansRemaining = indexHuman < compiledGame.totalHumans;
  bool environmentRemaining = indexEnv < totalEnvironment;
  bool particlesRemaining = indexParticle < totalParticles;

  while (true) {
    humansRemaining = indexHuman < compiledGame.totalHumans;
    environmentRemaining = indexEnv < totalEnvironment;
    particlesRemaining = indexParticle < totalParticles;
    zombiesRemaining = indexZombie < compiledGame.totalZombies;

    if (!zombiesRemaining &&
        !humansRemaining &&
        !environmentRemaining &&
        !particlesRemaining) return;

    if (humansRemaining) {
      double humanY = compiledGame.humans[indexHuman].y;

      if (!environmentRemaining ||
          humanY < compiledGame.environmentObjects[indexEnv].y) {
        if (!particlesRemaining ||
            humanY < compiledGame.particles[indexParticle].y) {
          if (!zombiesRemaining ||
              humanY < compiledGame.zombies[indexZombie].y) {
            drawCharacterMan(compiledGame.humans[indexHuman]);
            indexHuman++;
            continue;
          }
        }
      }
    }

    if (environmentRemaining) {
      EnvironmentObject env = compiledGame.environmentObjects[indexEnv];

      if (env.dst.top > screen.bottom) return;

      if (!particlesRemaining ||
          env.y < compiledGame.particles[indexParticle].y) {
        if (!zombiesRemaining || env.y < compiledGame.zombies[indexZombie].y) {
          drawEnvironmentObject(compiledGame.environmentObjects[indexEnv]);
          indexEnv++;
          continue;
        }
      }
    }

    if (particlesRemaining) {
      Particle particle = compiledGame.particles[indexParticle];

      if (!zombiesRemaining ||
          particle.y < compiledGame.zombies[indexZombie].y) {
        if (onScreen(particle.x, particle.y)) {
          drawParticle(particle);
        }
        indexParticle++;
        continue;
      }
    }

    drawCharacterZombie(compiledGame.zombies[indexZombie]);
    indexZombie++;
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
  drawImageRect(
      environmentObject.image, environmentObject.src, environmentObject.dst);
}

void _drawEnvironmentObjects() {
  for (EnvironmentObject environmentObject in compiledGame.environmentObjects) {
    globalCanvas.drawImage(
        mapEnvironmentObjectTypeToImage(environmentObject.type),
        Offset(environmentObject.x - _anchorX, environmentObject.y - _anchorY),
        paint);
  }
}

void _drawNpcBonusPointsCircles() {
  for (int i = 0; i < compiledGame.totalZombies; i++) {
    if (compiledGame.zombies[i].scoreMultiplier == "1") continue;
    Zombie npc = compiledGame.zombies[i];
    drawCircle(npc.x, npc.y, 10, colours.orange);
  }
}

void _drawPlayerHealthRing() {
  drawRing(_healthRing,
      percentage: player.health / player.maxHealth,
      color: healthColor,
      position: Offset(playerX, playerY));
}

void _drawCrates() {
  clear(render.crates);
  for (int i = 0; i < compiledGame.cratesTotal; i++) {
    render.crates.transforms
        .add(mapCrateToRSTransform((compiledGame.crates[i])));
    render.crates.rects.add(rectCrate);
  }
  drawAtlas(images.crate, render.crates.transforms, render.crates.rects);
}

void _drawCratesEditor() {
  for (Vector2 position in compiledGame.crates) {
    if (position.isZero) break;
    _drawCrate(position);
  }
}

void _drawCrate(Vector2 position) {
  drawCircle(position.x, position.y, 5, Colors.white);
  globalCanvas.drawImage(images.crate, Offset(position.x, position.y), paint);
}

void _renderItems() {
  clear(render.items);
  for (int i = 0; i < compiledGame.totalItems; i++) {
    render.items.transforms.add(mapItemToRSTransform(compiledGame.items[i]));
    render.items.rects.add(mapItemToRect(compiledGame.items[i].type));
  }
  drawAtlas(images.items, render.items.transforms, render.items.rects);
}

void _drawPlayerNames() {
  for (int i = 0; i < compiledGame.totalHumans; i++) {
    Character player = compiledGame.humans[i];
    if (player.x == compiledGame.playerX) continue;
    if (diff(mouseWorldX, player.x) > _nameRadius) continue;
    if (diff(mouseWorldY, player.y) > _nameRadius) continue;

    drawText(player.name, player.x - charWidth * player.name.length, player.y);
  }
}

void _writePlayerText() {
  for (int i = 0; i < compiledGame.totalHumans; i++) {
    Character human = compiledGame.humans[i];
    if (human.text.isEmpty) continue;

    double padding = 5;
    double width = charWidth * human.text.length;
    double left = human.x - width;
    double y = human.y - 50;
    paint.color = Colors.black26;
    globalCanvas.drawRect(
        Rect.fromLTWH(left - padding, y - 5, width * 2 + padding + padding, 30),
        paint);
    drawText(human.text, left, y);
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
      mouseWorldX, mouseWorldY, compiledGame.playerX, compiledGame.playerY);

  double mouseDistance = distance(mouseWorldX, mouseWorldY, playerX, playerY);
  double d = min(mouseDistance, weapon == Weapon.SniperRifle ? 150 : 35);
  double vX = velX(rot, d);
  double vY = velY(rot, d);
  Offset mouseOffset = Offset(mouseWorldX, mouseWorldY);
  Offset aimOffset = Offset(mouseWorldX + vX, mouseWorldY + vY);
  _drawLine(mouseOffset, aimOffset, Colors.white);
}

void _drawCollectables() {
  for (int i = 0; i < compiledGame.collectables.length; i += 3) {
    CollectableType type = CollectableType.values[compiledGame.collectables[i]];
    int x = compiledGame.collectables[i + 1];
    int y = compiledGame.collectables[i + 2];
    drawCollectable(type, x.toDouble(), y.toDouble());
  }
}

// TODO Optimize
void drawCollectable(CollectableType type, double x, double y) {}

void drawBlockSelected(Block block) {
  // globalCanvas.drawPath(block.wall1, _blockBlueGrey);
  // globalCanvas.drawPath(block.wall2, _blockBlue);
  // globalCanvas.drawPath(block.wall3, _blockGrey);
  // _drawLine(block.center, block.a, Colors.red);
  // _drawLine(block.center, block.b, Colors.green);
  // _drawLine(block.center, block.top, Colors.deepPurple);
  // _drawLine(block.center, block.right, Colors.orange);

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

void _drawBullets(List bullets) {
  for (int i = 0; i < compiledGame.totalBullets; i++) {
    drawBullet(compiledGame.bullets[i].x, compiledGame.bullets[i].y);
  }
}
