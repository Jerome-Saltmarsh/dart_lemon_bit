import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/classes/Item.dart';
import 'package:gamestream_flutter/classes/Projectile.dart';
import 'package:gamestream_flutter/classes/Structure.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:gamestream_flutter/isometric/render/render_character.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:gamestream_flutter/utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';

import '../modules.dart';

class IsometricRender {
  final IsometricModule state;

  IsometricRender(this.state);

  int calculateOrder(Vector3 position) {
    return convertWorldToRow(position.x, position.y) +
        convertWorldToColumn(position.x, position.y);
  }

  /// While this method is obviously a complete dog's breakfast all readability
  /// has been sacrificed for sheer speed of execution.
  ///
  /// WARNING: Be very careful modifying anything in this code. If something
  /// doesn't make any sense or doesn't seem to belong or do anything look
  /// harder

  void renderProjectile(Projectile value) {
    switch (value.type) {
      case ProjectileType.Arrow:
        renderArrow(value.renderX, value.renderY, value.angle);
        break;
      case ProjectileType.Orb:
        renderOrb(value.renderX, value.renderY);
        break;
      case ProjectileType.Fireball:
        renderFireball(value.renderX, value.renderY, value.angle);
        break;
      case ProjectileType.Bullet:
        renderFireball(value.renderX, value.renderY, value.angle);
        break;
      default:
        return;
    }
  }

  void renderFireball(double x, double y, double rotation) {
    engine.renderCustom(
      dstX: x,
      dstY: y,
      srcX: 5669,
      srcY: ((x + y + (engine.frame ~/ 5) % 6) * 23),
      srcWidth: 18,
      srcHeight: 23,
      rotation: rotation,
    );
  }

  void renderArrow(double x, double y, double angle) {
    engine.mapSrc(x: 2182, y: 1, width: 13, height: 47);
    engine.mapDst(
        x: x,
        y: y - 20,
        rotation: angle + piQuarter,
        anchorX: 6.5,
        anchorY: 30,
        scale: 0.5);
    engine.renderAtlas();
    engine.mapSrc(x: 2172, y: 1, width: 13, height: 47);
    engine.mapDst(
        x: x,
        y: y,
        rotation: angle + piQuarter,
        anchorX: 6.5,
        anchorY: 30,
        scale: 0.5);
    engine.renderAtlas();
  }

  void renderOrb(double x, double y) {
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 417,
        srcY: 26,
        srcWidth: 8,
        srcHeight: 8,
        scale: 1.5);
  }

  void renderStructure(Structure structure) {
    switch (structure.type) {
      case StructureType.Tower:
        return renderTower(structure.x, structure.y);
      case StructureType.Palisade:
        return renderPalisade(x: structure.x, y: structure.y);
      // case StructureType.Torch:
      //   return renderTorch(structure);
      case StructureType.House:
        return renderHouse(structure);
    }
  }

  void renderPalisade(
      {required double x, required double y, int shade = Shade.Bright}) {
    engine.renderCustom(
      dstX: x,
      dstY: y,
      srcX: 1314,
      srcY: shade * 96,
      srcWidth: 48,
      srcHeight: 96,
      anchorY: 0.66,
    );
  }

  void renderBlockGrass(Position position) {
    render(
        position: position, srcX: 5981, width: 48, height: 100, anchorY: 0.66);
  }

  void renderBlockGrassLevel2(Position position) {
    final shade = isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y - 50,
      srcX: 5981,
      srcY: shade * 100,
      srcWidth: 48,
      srcHeight: 100,
      anchorY: 0.66,
    );
  }

  void renderBlockGrassLevel3(Position position) {
    final shade = isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y - 100,
      srcX: 5981,
      srcY: shade * 100,
      srcWidth: 48,
      srcHeight: 100,
      anchorY: 0.66,
    );
  }

  void renderStairsGrassH(Position position) {
    final shade = isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y,
      srcX: 5870,
      // srcY: shade * 100,
      srcY: 0,
      srcWidth: 48,
      srcHeight: 100,
      anchorY: 0.66,
    );
  }

  void renderTower(double x, double y) {
    engine.renderCustom(
        dstX: x,
        dstY: y,
        srcX: 6125,
        srcY: 0,
        srcWidth: 48,
        srcHeight: 100,
        anchorY: 0.66);
  }

  void renderHouse(Position position) {
    engine.renderCustomV2(
        dst: position, srcX: 1748, srcWidth: 150, srcHeight: 150);
  }

  void renderPot(Position position) {
    engine.mapSrc64(x: 6032, y: isometric.getShadeAt(position) * 64);
    engine.mapDst(x: position.x, y: position.y, anchorX: 32, anchorY: 32);
    engine.renderAtlas();
  }

  void renderTree(Position position) {
    render(position: position, srcX: 2049, width: 64, height: 81, anchorY: 0.66);
  }

  void renderChest(Position position) {
    render(
        position: position,
        srcX: 6328,
        width: 50,
        height: 76,
        anchorY: 0.6,
        scale: 0.75);
  }

  void renderItem(Item item) {
    srcLoopSimple(
      x: 5939,
      size: 32,
      frames: 4,
    );
    engine.mapDst(anchorX: 16, anchorY: 23, x: item.x, y: item.y);
    engine.renderAtlas();
  }

  void srcLoopSimple(
      {required double x, required int frames, required double size}) {
    engine.mapSrc(
        x: x, y: ((engine.frame % 4) * size), width: size, height: size);
  }


  void renderRockSmall(Position position) {
    render(position: position, srcX: 5569, width: 12, height: 14);
  }

  void renderFireplace(Position position) {
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y,
      srcY: ((position.x + position.y + engine.frame) % 6) * 43,
      srcX: 6464,
      srcWidth: 46,
      srcHeight: 43,
    );
  }

  void renderFlag(Position position) {
    render(position: position, srcX: 6437, width: 19, height: 33);
  }

  void renderLongGrass(Position position) {
    render(position: position, srcX: 5585, width: 19, height: 30);
  }

  void renderRockLarge(Position position) {
    render(position: position, srcX: 5475, width: 40, height: 43);
  }

  void renderGrave(Position position) {
    render(position: position, srcX: 5524, width: 20, height: 41);
  }

  void renderTreeStump(Position position) {
    render(position: position, srcX: 5549, width: 15, height: 22);
  }

  void render({
    required Position position,
    required double srcX,
    required double width,
    required double height,
    double anchorY = 0.5,
    double scale = 1.0,
  }) {
    final shade = isometric.getShadeAt(position);
    if (shade >= Shade.Pitch_Black) return;
    engine.renderCustomV2(
      dst: position,
      srcX: srcX,
      srcY: shade * height,
      srcWidth: width,
      srcHeight: height,
      anchorY: anchorY,
      scale: scale,
    );
  }

  void drawInteractableNpc(Character npc) {
    renderCharacter(npc);
    if (diffOver(npc.x, mouseWorldX, 50)) return;
    if (diffOver(npc.y, mouseWorldY, 50)) return;
    engine.renderText(npc.name, npc.x - 4.5 * npc.name.length, npc.y,
        style: state.nameTextStyle);
  }

  void renderCircle36V2(Position position) {
    renderCircle36(position.x, position.y);
  }

  void renderCircle36(double x, double y) {
    engine.render(dstX: x, dstY: y, srcX: 2420, srcY: 57, srcSize: 37);
  }

  void renderIconWood(Vector2 position) {
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y,
      srcX: 6189,
      srcWidth: 26,
      srcHeight: 37,
      anchorY: 0.66,
    );
  }

  void renderIconStone(Vector2 position) {
    engine.renderCustom(
      dstX: position.x,
      dstY: position.y,
      srcX: 6216,
      srcWidth: 26,
      srcHeight: 36,
      anchorY: 0.66,
    );
  }

  void renderIconCoin(Vector2 position) {
    engine.renderCustomV2(
      dst: position,
      srcX: 6245,
      srcWidth: 25,
      srcHeight: 32,
      anchorY: 0.66,
    );
  }

  void renderIconGold(Vector2 position) {
    engine.renderCustomV2(
      dst: position,
      srcX: 6273,
      srcWidth: 26,
      srcHeight: 32,
      anchorY: 0.66,
    );
  }

  void renderIconExperience(Vector2 position) {
    engine.renderCustomV2(
      dst: position,
      srcX: 6304,
      srcWidth: 17,
      srcHeight: 26,
      anchorY: 0.66,
    );
  }

  final _mouseSnap = Vector2(0, 0);

  void renderBuildMode() {
    final value = modules.game.structureType.value;
    if (value == null) return;

    final x = getMouseSnapX();
    final y = getMouseSnapY();
    _mouseSnap.x = x;
    _mouseSnap.y = y;

    switch (modules.game.structureType.value) {
      case StructureType.Tower:
        return isometric.render.renderTower(x, y);
      case StructureType.Palisade:
        return isometric.render.renderPalisade(x: x, y: y);
      // case StructureType.Torch:
      //   return isometric.render.renderTorch(_mouseSnap);
      default:
        return;
    }
  }

  void renderWireFrameBlue(int row, int column, int z) {
    return engine.renderCustom(
      dstX: getTileWorldX(row, column),
      dstY: getTileWorldY(row, column) - (z * 24),
      srcX: 7590,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
  }

  void renderWireFrameRed(int row, int column, int z) {
    return engine.renderCustom(
      dstX: getTileWorldX(row, column),
      dstY: getTileWorldY(row, column) - (z * 24),
      srcX: 7638,
      srcWidth: 48,
      srcHeight: 72,
      anchorY: 0.3334,
    );
  }

  void renderArrowUp(double x, double y) {
    return engine.renderCustom(
      dstX: x,
      dstY: y,
      srcX: 6993,
      srcWidth: 13,
      srcHeight: 29,
      anchorY: 1.0,
    );
  }
}

class SpriteLayer {
  static const Shadow = 0;
  static const Legs_Blue = 1;
  static const Legs_Swat = 2;
  static const Staff_Wooden = 3;
  static const Sword_Wooden = 4;
  static const Sword_Steel = 5;
  static const Weapon_Shotgun = 6;
  static const Weapon_Handgun = 7;
  static const Bow_Wooden = 8;
  static const Body_Cyan = 9;
  static const Body_Blue = 10;
  static const Body_Swat = 11;
  static const Head_Plain = 12;
  static const Head_Steel = 13;
  static const Head_Rogue = 14;
  static const Head_Magic = 15;
  static const Head_Swat = 16;
}
