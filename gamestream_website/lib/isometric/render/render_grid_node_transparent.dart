// import 'package:bleed_common/library.dart';
// import 'package:gamestream_flutter/isometric/grid.dart';
// import 'package:lemon_engine/engine.dart';
// import 'package:lemon_engine/render.dart';
//
// import '../watches/ambient_shade.dart';
// import 'render_torch.dart';
//
// void renderGridNodeTransparent(int z, int row, int column, int type) {
//   const srcTop = 433.0;
//   const srcLeft = 7110.0;
//
//   assert (type != GridNodeType.Empty);
//   final dstX = (row - column) * tileSizeHalf;
//   final dstY = ((row + column) * tileSizeHalf) - (z * tileHeight);
//   final shade = gridLightDynamic[z][row][column];
//   switch (type) {
//     case GridNodeType.Bricks:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: srcLeft,
//         srcY: srcTop + (72.0 * shade),
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Grass:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 7158,
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorX: 0.5,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Rain_Falling:
//       return;
//     case GridNodeType.Rain_Landing:
//       return;
//       // return render(
//       //   dstX: dstX,
//       //   dstY: dstY - tileHeight,
//       //   srcX: 6788,
//       //   srcY: 72.0 * animationFrameRain,
//       //   srcWidth: 48,
//       //   srcHeight: 72,
//       //   anchorY: 0.3334,
//       //   color: colorShades[shade],
//       // );
//     case GridNodeType.Stairs_South:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 7398,
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Stairs_West:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 7446,
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Stairs_North:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 7494,
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Stairs_East:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 7542,
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Water:
//       final animationFrame = (engine.frame ~/ 15) % 4;
//       var height = 1;
//       if (animationFrame == 1) {
//         height = 2;
//       } else if (animationFrame == 3) {
//         height = 0;
//       }
//       return render(
//         dstX: dstX,
//         dstY: dstY + height,
//         srcX: 7206 + (animationFrame * 48),
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//
//     case GridNodeType.Torch:
//       if (ambientShade.value <= Shade.Very_Bright) {
//         return renderTorchOff(dstX, dstY);
//       }
//       return renderTorchOn(dstX, dstY);
//
//     case GridNodeType.Tree_Bottom:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 1603,
//         srcY: 68.0 * shade,
//         srcWidth: 62.0,
//         srcHeight: 68.0,
//         anchorY: 0.6,
//       );
//     case GridNodeType.Tree_Top:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 1603 + 62,
//         srcY: 68.0 * shade,
//         srcWidth: 62.0,
//         srcHeight: 68.0,
//         anchorY: 0.33,
//       );
//
//     case GridNodeType.Player_Spawn:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 7686,
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Grass_Long:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: 7734,
//         srcY: srcTop + 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorX: 0.5,
//         anchorY: 0.3334,
//       );
//     default:
//       return render(
//         dstX: dstX,
//         dstY: dstY,
//         srcX: srcLeft,
//         srcY: srcTop + (72.0 * shade),
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//   }
// }
