import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/state/grid.dart';
import 'package:lemon_engine/engine.dart';

import 'render_torch.dart';
import 'render_tree.dart';

void renderGridNode(int z, int row, int column, int type) {
  if (type == GridNodeType.Empty) return;

  final dstX = getTileWorldX(row, column);
  final dstY = getTileWorldY(row, column) - (z * 24);
  final shade = gridLightDynamic[z][row][column];
  switch (type) {
    case GridNodeType.Bricks:
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY,
        srcX: 7110,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Grass:
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY,
        srcX: 7158,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_South:
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY,
        srcX: 7398,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_West:
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY,
        srcX: 7446,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_North:
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY,
        srcX: 7494,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_East:
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY,
        srcX: 7542,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Water:
      final animationFrame = (engine.frame ~/ 15) % 4;
      var height = 1;
      if (animationFrame == 1) {
        height = 2;
      } else if (animationFrame == 3) {
        height = 0;
      }
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY + height,
        srcX: 7206 + (animationFrame * 48),
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );

    case GridNodeType.Torch:
      if (ambient.value <= Shade.Very_Bright) {
        return renderTorchOff(dstX, dstY);
      }
      return renderTorchOn(dstX, dstY);

    case GridNodeType.Tree:
      return renderTreeAt(z, row, column);

    case GridNodeType.Player_Spawn:
      return engine.renderCustom(
        dstX: dstX,
        dstY: dstY,
        srcX: 7686,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    default:
      throw Exception("Cannot render grid node type $type");
  }
}
