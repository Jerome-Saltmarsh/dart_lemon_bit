import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';

import 'render_torch.dart';

void renderGridNode(int z, int row, int column, int type) {
  assert (type != GridNodeType.Empty);
  final dstX = (row - column) * tileSizeHalf;
  final dstY = ((row + column) * tileSizeHalf) - (z * 24);
  final shade = gridLightDynamic[z][row][column];
  switch (type) {
    case GridNodeType.Bricks:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7110,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Grass:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7158,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_South:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7398,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_West:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7446,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_North:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7494,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Stairs_East:
      return render(
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
      return render(
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

    case GridNodeType.Tree_Bottom_Pine:
      return render(
          dstX: dstX,
          dstY: dstY,
          srcX: 1478,
          srcY: 68.0 * shade,
          srcWidth: 62.0,
          srcHeight: 68.0,
          anchorY: 0.6,
      );
    case GridNodeType.Tree_Top_Pine:
      return render(
          dstX: dstX,
          dstY: dstY,
          srcX: 1478 + 62,
          srcY: 68.0 * shade,
          srcWidth: 62.0,
          srcHeight: 68.0,
          anchorY: 0.33,
      );

    case GridNodeType.Player_Spawn:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7686,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Grass_Long:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7734,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );
    case GridNodeType.Wooden_Wall_Row:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7782,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );
    default:
      throw Exception("Cannot render grid node type $type");
  }
}

void renderWireFrameBlue(int row, int column, int z) {
  return render(
    dstX: getTileWorldX(row, column),
    dstY: getTileWorldY(row, column) - (z * 24),
    srcX: 7590,
    srcY: 0,
    srcWidth: 48,
    srcHeight: 72,
    anchorY: 0.3334,
  );
}

void renderWireFrameRed(int row, int column, int z) {
  return render(
    dstX: getTileWorldX(row, column),
    dstY: getTileWorldY(row, column) - (z * 24),
    srcX: 7638,
    srcY: 0,
    srcWidth: 48,
    srcHeight: 72,
    anchorY: 0.3334,
  );
}