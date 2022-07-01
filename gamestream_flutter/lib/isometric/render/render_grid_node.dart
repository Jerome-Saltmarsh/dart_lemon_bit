import 'package:bleed_common/grid_node_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/wind.dart';
import 'package:gamestream_flutter/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/grid.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:lemon_engine/render.dart';

import '../grid/state/wind.dart';
import 'render_torch.dart';
import 'weather.dart';

void renderGridNode(int z, int row, int column, int type, double dstY, int shade) {
  final dstX = (row - column) * tileSizeHalf;
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
        srcX: 7158 ,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );

    case GridNodeType.Wood:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7590 ,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );
    case GridNodeType.Grass_Long:
      final wind = gridWind[z][row][column];
      switch (wind){
        case Wind.Calm:
          return render(
            dstX: dstX,
            dstY: dstY,
            srcX: 5678,
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorX: 0.5,
            anchorY: 0.3334,
          );
        case Wind.Gentle:
          return render(
            dstX: dstX,
            dstY: dstY,
            srcX: 5678 + ((((row - column) + animationFrameGrass) % 4) * 48),
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorX: 0.5,
            anchorY: 0.3334,
          );
         default:
          return render(
            dstX: dstX,
            dstY: dstY,
            srcX: 5877 + ((((row - column) + animationFrameGrass) % 4) * 48),
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorX: 0.5,
            anchorY: 0.3334,
          );
      }

    case GridNodeType.Rain_Landing:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 6592,
        srcY: 72.0 * animationFrameRain,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
        color: colorShades[shade],
      );
    case GridNodeType.Rain_Falling:
      return render(
        dstX: dstX - rainPosition,
        dstY: dstY + animationFrameRain,
        srcX: 6544,
        srcY: 72.0 * animationFrameRain,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
        color: colorShades[shade],
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
      render(
        dstX: dstX,
        dstY: dstY + animationFrameWaterHeight,
        srcX: 7206 + animationFrameWaterSrcX,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );

      if (raining){
        render(
          dstX: dstX,
          dstY: dstY - tileHeight,
          srcX: 6788,
          srcY: 72.0 * animationFrameRain,
          srcWidth: 48,
          srcHeight: 72,
          anchorY: 0.3334,
          color: colorShades[shade],
        );
      }
      return;
    case GridNodeType.Torch:
      if (ambient.value <= Shade.Very_Bright) {
        return renderTorchOff(dstX, dstY);
      }
      return renderTorchOn(dstX, dstY);

    case GridNodeType.Tree_Bottom:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 1478,
        srcY: 68.0 * shade,
        srcWidth: 62.0,
        srcHeight: 68.0,
        anchorY: 0.6,
      );
    case GridNodeType.Tree_Top:
      final wind = gridWind[z][row][column];
      animationFrameTreePosition = treeAnimation[(row - column + animationFrame) % treeAnimation.length] * wind;
      return render(
        dstX: dstX + (animationFrameTreePosition * 0.5),
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
    case GridNodeType.Enemy_Spawn:
      if (!playModeEdit) return;
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7686,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Fireplace:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 6469,
        srcY: (((row + column + (animationFrameTorch)) % 6) * 72),
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    default:
      throw Exception("Cannot render grid node type $type");
  }
}

