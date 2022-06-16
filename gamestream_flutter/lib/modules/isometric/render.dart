import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/classes/item.dart';
import 'package:gamestream_flutter/isometric/classes/structure.dart';
import 'package:gamestream_flutter/isometric/classes/character.dart';
import 'package:gamestream_flutter/isometric/render/render_character.dart';
import 'package:gamestream_flutter/modules/isometric/module.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

class IsometricRender {
  final IsometricModule state;

  IsometricRender(this.state);

  /// While this method is obviously a complete dog's breakfast all readability
  /// has been sacrificed for sheer speed of execution.
  ///
  /// WARNING: Be very careful modifying anything in this code. If something
  /// doesn't make any sense or doesn't seem to belong or do anything look
  /// harder

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
    // engine.renderCustom(
    //   dstX: x,
    //   dstY: y,
    //   srcX: 1314,
    //   srcY: shade * 96,
    //   srcWidth: 48,
    //   srcHeight: 96,
    //   anchorY: 0.66,
    // );
  }

  void renderBlockGrass(Position position) {
    // render(
    //     position: position, srcX: 5981, width: 48, height: 100, anchorY: 0.66);
  }

  void renderBlockGrassLevel2(Position position) {
    // final shade = isometric.getShadeAt(position);
    // if (shade >= Shade.Pitch_Black) return;
    // engine.renderCustom(
    //   dstX: position.x,
    //   dstY: position.y - 50,
    //   srcX: 5981,
    //   srcY: shade * 100,
    //   srcWidth: 48,
    //   srcHeight: 100,
    //   anchorY: 0.66,
    // );
  }

  void renderBlockGrassLevel3(Position position) {
    // final shade = isometric.getShadeAt(position);
    // if (shade >= Shade.Pitch_Black) return;
    // engine.renderCustom(
    //   dstX: position.x,
    //   dstY: position.y - 100,
    //   srcX: 5981,
    //   srcY: shade * 100,
    //   srcWidth: 48,
    //   srcHeight: 100,
    //   anchorY: 0.66,
    // );
  }

  void renderStairsGrassH(Position position) {
    // final shade = isometric.getShadeAt(position);
    // if (shade >= Shade.Pitch_Black) return;
    // engine.renderCustom(
    //   dstX: position.x,
    //   dstY: position.y,
    //   srcX: 5870,
    //   // srcY: shade * 100,
    //   srcY: 0,
    //   srcWidth: 48,
    //   srcHeight: 100,
    //   anchorY: 0.66,
    // );
  }

  void renderTower(double x, double y) {
    // engine.renderCustom(
    //     dstX: x,
    //     dstY: y,
    //     srcX: 6125,
    //     srcY: 0,
    //     srcWidth: 48,
    //     srcHeight: 100,
    //     anchorY: 0.66);
  }

  void renderHouse(Position position) {
    // engine.renderCustomV2(
    //     dst: position, srcX: 1748, srcWidth: 150, srcHeight: 150);
  }

  void renderPot(Position position) {
    // engine.mapSrc64(x: 6032, y: isometric.getShadeAt(position) * 64);
    // engine.mapDst(x: position.x, y: position.y, anchorX: 32, anchorY: 32);
    // engine.renderAtlas();
  }

  void renderTree(Position position) {
    // render(position: position, srcX: 2049, width: 64, height: 81, anchorY: 0.66);
  }

  void renderChest(Position position) {
    // render(
    //     position: position,
    //     srcX: 6328,
    //     width: 50,
    //     height: 76,
    //     anchorY: 0.6,
    //     scale: 0.75);
  }

  void renderItem(Item item) {
    // srcLoopSimple(
    //   x: 5939,
    //   size: 32,
    //   frames: 4,
    // );
    // engine.mapDst(anchorX: 16, anchorY: 23, x: item.x, y: item.y);
    // engine.renderAtlas();
  }


  void renderRockSmall(Position position) {
    // render(position: position, srcX: 5569, width: 12, height: 14);
  }

  void renderFireplace(Position position) {
    render(
      dstX: position.x,
      dstY: position.y,
      srcY: ((position.x + position.y + engine.frame) % 6) * 43,
      srcX: 6464,
      srcWidth: 46,
      srcHeight: 43,
    );
  }

  void renderFlag(Position position) {
    // render(position: position, srcX: 6437, width: 19, height: 33);
  }

  void renderLongGrass(Position position) {
    // render(position: position, srcX: 5585, width: 19, height: 30);
  }

  void renderRockLarge(Position position) {
    // render(position: position, srcX: 5475, width: 40, height: 43);
  }

  void renderGrave(Position position) {
    // render(position: position, srcX: 5524, width: 20, height: 41);
  }

  void renderTreeStump(Position position) {
    // render(position: position, srcX: 5549, width: 15, height: 22);
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
    // engine.render(dstX: x, dstY: y, srcX: 2420, srcY: 57, srcSize: 37);
  }



  final _mouseSnap = Vector2(0, 0);

  void renderArrowUp(double x, double y) {
    return render(
      dstX: x,
      dstY: y,
      srcX: 6993,
      srcY: 0,
      srcWidth: 13,
      srcHeight: 29,
      anchorY: 1.0,
    );
  }
}

