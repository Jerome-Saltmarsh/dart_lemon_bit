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
import 'package:bleed_client/common/enums/EnvironmentObjectType.dart';
import 'package:bleed_client/editor/render/drawEditor.dart';
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
import 'package:bleed_client/mappers/mapTileToSrcRect.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/network/state/connected.dart';
import 'package:bleed_client/properties.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/render/drawCharacterMan.dart';
import 'package:bleed_client/render/drawCharacterZombie.dart';
import 'package:bleed_client/render/functions/applyLightingToCharacters.dart';
import 'package:bleed_client/state/colours.dart';
import 'package:bleed_client/state/getTileAt.dart';
import 'package:bleed_client/state/settings.dart';
import 'package:bleed_client/ui/compose/hudUI.dart';
import 'package:bleed_client/ui/state/hudState.dart';
import 'package:bleed_client/variables/ambientLight.dart';
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
final double _light = 100;
final double _medium = 250;
final double _dark = 400;
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

void calculateTileSrcRects() {
  int i = 0;
  List<List<Tile>> _tiles = compiledGame.tiles;

  for (int row = 0; row < _tiles.length; row++) {
    for (int column = 0; column < _tiles[0].length; column++) {
      Shading shading = render.dynamicShading[row][column];

      if (shading == Shading.VeryDark) {
        render.tilesRects[i] = rectSrcDarkness.left;
        render.tilesRects[i + 2] = rectSrcDarkness.right;
        i += 4;
        continue;
      }

      Rect rect = mapTileToSrcRect(_tiles[row][column]);
      double left = rect.left;

      if (shading == Shading.Medium) {
        left += 48;
      } else if (shading == Shading.Dark) {
        left += 96;
      }

      render.tilesRects[i] = left;
      render.tilesRects[i + 2] = left + 48;
      i += 4;
    }
  }
}

void setTileType(int index, double frame) {
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
    if (ambientLight != Shading.Bright) {
      _flameIndex = (_flameIndex + 1) % 3;
      for (EnvironmentObject torch in compiledGame.torches) {
        torch.image = images.flames[_flameIndex];
      }
    }
  }

  for (int row = 0; row < render.dynamicShading.length; row++) {
    for (int column = 0; column < render.dynamicShading[0].length; column++) {
      render.dynamicShading[row][column] = render.bakeMap[row][column];
    }
  }

  applyCharacterLightEmission(compiledGame.humans);
  applyCharacterLightEmission(compiledGame.interactableNpcs);
  applyLightingToEnvironmentObjects();

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

void applyLightingToEnvironmentObjects() {
  for (EnvironmentObject environmentObject in compiledGame.environmentObjects) {
    Shading shade = render.dynamicShading[environmentObject.tileRow]
        [environmentObject.tileColumn];

    if (shade == Shading.VeryDark) {
      environmentObject.image = images.empty;
      continue;
    }

    if (environmentObject.type == EnvironmentObjectType.Rock) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.rockBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.rockMedium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.rockDark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Tree01) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.tree01Bright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.tree01Medium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.tree01Dark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Tree02) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.tree02Bright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.tree02Medium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.tree02Dark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Palisade) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.palisadeBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.palisadeMedium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.palisadeDark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Palisade_H) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.palisadeHBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.palisadeHMedium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.palisadeHDark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Palisade_V) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.palisadeVBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.palisadeVMedium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.palisadeVDark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Tree_Stump) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.treeStumpBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.treeStumpMedium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.treeStumpDark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Rock_Small) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.rockSmallBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.rockSmallMedium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.rockSmallDark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.Grave) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.graveBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.graveMedium;
          continue;
        case Shading.Dark:
          environmentObject.image = images.graveDark;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.House01) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.houseDay;
          continue;
        default:
          environmentObject.image = images.house;
          continue;
      }
    } else if (environmentObject.type == EnvironmentObjectType.LongGrass) {
      switch (shade) {
        case Shading.Bright:
          environmentObject.image = images.longGrassBright;
          continue;
        case Shading.Medium:
          environmentObject.image = images.longGrassNormal;
          continue;
        case Shading.Dark:
          environmentObject.image = images.longGrassDark;
          continue;
      }
    }
  }
}

void applyShade(
    List<List<Shading>> shader, int row, int column, Shading value) {
  if (shader[row][column].index <= value.index) return;
  shader[row][column] = value;
}

void applyShadeBright(List<List<Shading>> shader, int row, int column) {
  applyShade(shader, row, column, Shading.Bright);
}

void applyShadeMedium(List<List<Shading>> shader, int row, int column) {
  applyShade(shader, row, column, Shading.Medium);
}

void applyShadeDark(List<List<Shading>> shader, int row, int column) {
  applyShade(shader, row, column, Shading.Dark);
}

void applyLightMedium(List<List<Shading>> shader, double x, double y) {
  int column = getColumn(x, y);
  int row = getRow(x, y);
  applyShadeMedium(shader, row, column);

  if (row > 1) {
    applyShadeDark(shader, row - 2, column);
    if (column > 0) {
      applyShadeDark(shader, row - 2, column - 1);
    }
    if (column > 1) {
      applyShadeDark(shader, row - 2, column - 2);
    }
    if (column < compiledGame.totalColumns - 1) {
      applyShadeDark(shader, row - 2, column + 1);
    }
    if (column < compiledGame.totalColumns - 2) {
      applyShadeDark(shader, row - 2, column + 2);
    }
  }
  if (row < compiledGame.totalRows - 2) {
    applyShadeDark(shader, row + 2, column);

    if (column > 0) {
      applyShadeDark(shader, row + 2, column - 1);
    }
    if (column > 1) {
      applyShadeDark(shader, row + 2, column - 2);
    }
    if (column < compiledGame.totalColumns - 1) {
      applyShadeDark(shader, row + 2, column + 1);
    }
    if (column < compiledGame.totalColumns - 2) {
      applyShadeDark(shader, row + 2, column + 2);
    }
  }

  if (column > 0) {
    applyShadeDark(shader, row, column - 2);

    if (row > 0) {
      applyShadeDark(shader, row - 1, column - 2);
    }
    if (row < compiledGame.totalRows - 1) {
      applyShadeDark(shader, row + 1, column - 2);
    }
  }
  if (column < compiledGame.totalColumns - 1) {
    applyShadeDark(shader, row, column + 2);

    if (row > 0) {
      applyShadeDark(shader, row - 1, column + 2);
    }
    if (row < compiledGame.totalRows - 1) {
      applyShadeDark(shader, row + 1, column + 2);
    }
  }

  if (row > 0) {
    applyShadeMedium(shader, row - 1, column);
    if (column > 0) {
      applyShadeMedium(shader, row - 1, column - 1);
    }
    if (column + 1 < compiledGame.totalColumns) {
      applyShadeMedium(shader, row - 1, column + 1);
    }
  }
  if (column > 0) {
    applyShadeMedium(shader, row, column - 1);
  }
  if (column + 1 < compiledGame.totalColumns) {
    applyShadeMedium(shader, row, column + 1);
    if (row + 1 < compiledGame.totalRows) {
      applyShadeMedium(shader, row + 1, column + 1);
    }
  }
  if (row + 1 < compiledGame.totalRows) {
    applyShadeMedium(shader, row + 1, column);

    if (column > 0) {
      applyShadeMedium(shader, row + 1, column - 1);
    }
  }
}

Shading calculateShadeAt(double x, double y) {
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
  return shading;
}

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
