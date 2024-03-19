// import 'package:amulet_common/src.dart';
// import 'package:amulet_client/amulet/getters/get_src_amulet_item.dart';
// import 'package:flutter/material.dart';
// import 'package:lemon_lang/src.dart';
//
// class AmuletItemImage extends StatelessWidget {
//   final double scale;
//   final AmuletItem amuletItem;
//
//   AmuletItemImage({
//     required this.amuletItem,
//     required this.scale,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const size = 32.0;
//     final src = getSrcAmuletItem(amuletItem);
//     return AmuletImage(
//       srcX: src[0],
//       srcY: src[1],
//       width: src.tryGet(2) ?? size,
//       height: src.tryGet(3) ?? size,
//       scale: scale,
//     );
//   }
// }
//
//
// class AmuletImage extends StatelessWidget {
//
//   final double srcX;
//   final double srcY;
//   final double width;
//   final double height;
//   final double scale;
//   final double dstX;
//   final double dstY;
//
//   AmuletImage({
//     required this.srcX,
//     required this.srcY,
//     required this.width,
//     required this.height,
//     this.scale = 1,
//     this.dstX = 0,
//     this.dstY = 0,
//   });
//
//   @override
//   Widget build(BuildContext context) =>
//       IsometricBuilder(
//           builder: (context, isometric) =>
//               isometric.engine.buildAtlasImage(
//                 image: isometric.images.atlas_amulet_items,
//                 srcX: srcX,
//                 srcY: srcY,
//                 srcWidth: width,
//                 srcHeight: height,
//                 scale: scale,
//                 dstX: dstX,
//                 dstY: dstY,
//               )
//       );
// }