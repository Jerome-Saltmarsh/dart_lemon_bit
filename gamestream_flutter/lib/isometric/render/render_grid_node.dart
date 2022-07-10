import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/isometric/constants/color_pitch_black.dart';
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:gamestream_flutter/isometric/play_mode.dart';
import 'package:gamestream_flutter/isometric/watches/torches_ignited.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';

import '../grid/state/wind.dart';
import '../variables/src_x_rain_falling.dart';
import '../variables/src_x_rain_landing.dart';
import 'render_torch.dart';

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
      final wind = gridWind[z][row][column];
      switch(wind){
        case windIndexCalm:
          return render(
            dstX: dstX,
            dstY: dstY,
            srcX: 5267,
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
            srcX: 5267 + ((((row - column) + animationFrameGrassShort) % 6) * 48),
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorX: 0.5,
            anchorY: 0.3334,
          );
      }

    case GridNodeType.Grass_Slope_West:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7781 ,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );

    case GridNodeType.Grass_Slope_South:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7829 ,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );
    case GridNodeType.Grass_Slope_East:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7877 ,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorX: 0.5,
        anchorY: 0.3334,
      );
    case GridNodeType.Grass_Slope_North:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 7925 ,
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
        case windIndexCalm:
          return render(
            dstX: dstX,
            dstY: dstY,
            srcX: 4856,
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorX: 0.5,
            anchorY: 0.3334,
          );
        case windIndexGentle:
          return render(
            dstX: dstX,
            dstY: dstY,
            srcX: 4856 + ((((row - column) + animationFrameGrass) % 4) * 48),
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
            srcX: 5048 + ((((row - column) + animationFrameGrass) % 4) * 48),
            srcY: 72.0 * shade,
            srcWidth: 48,
            srcHeight: 72,
            anchorX: 0.5,
            anchorY: 0.3334,
          );
      }

    case GridNodeType.Rain_Falling:
      return render(
        dstX: dstX - rainPosition,
        dstY: dstY + animationFrameRain,
        srcX: srcXRainFalling,
        srcY: 72.0 * animationFrameRain,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
        color: colorShades[shade],
      );

    case GridNodeType.Rain_Landing:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: srcXRainLanding,
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
    case GridNodeType.Brick_Top:
      return render(
        dstX: dstX,
        dstY: dstY,
        srcX: 8621,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Wood_Half_Row_1:
      return renderBlock(dstX: dstX, dstY: dstY, srcX: 8887, shade: shade);
    case GridNodeType.Wood_Half_Column_1:
      return renderBlock(dstX: dstX, dstY: dstY, srcX: 8935, shade: shade);
    case GridNodeType.Wood_Corner_Bottom:
      return renderBlock(dstX: dstX, dstY: dstY, srcX: 8983, shade: shade);
    case GridNodeType.Water:
      return render(
        dstX: dstX,
        dstY: dstY + animationFrameWaterHeight,
        srcX: 7206 + animationFrameWaterSrcX,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Water_Flowing:
      return render(
        dstX: dstX,
        dstY: dstY + animationFrameWaterHeight,
        srcX: 8096 + animationFrameWaterSrcX,
        srcY: 72.0 * shade,
        srcWidth: 48,
        srcHeight: 72,
        anchorY: 0.3334,
      );
    case GridNodeType.Torch:
      if (!torchesIgnited.value) {
        return renderTorchOff(dstX, dstY);
      }
      final wind = gridWind[z][row][column];

      if (wind == Wind.Calm){
        return renderTorchOn(dstX, dstY);
      }
      return renderTorchOnWindy(dstX, dstY);

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

void renderBlock({
  required double dstX,
  required double dstY,
  required double srcX,
  required int shade
}){

  const spriteWidth = 48.0;
  const spriteHeight = 72.0;
  const spriteWidthHalf = 24.0;
  const spriteHeightHalf = 36.0;

  final srcY = shade * spriteHeight;

  src[bufferIndex] = srcX;
  dst[bufferIndex] = 1;
  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = 0;
  bufferIndex++;

  src[bufferIndex] = srcX + spriteWidth;
  dst[bufferIndex] = dstX - spriteWidthHalf;

  bufferIndex++;
  src[bufferIndex] = srcY + spriteHeight;
  dst[bufferIndex] = dstY - spriteHeightHalf;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;

  engine.renderAtlas();
}

