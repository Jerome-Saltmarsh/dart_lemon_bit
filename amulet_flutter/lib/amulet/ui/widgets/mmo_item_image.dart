// import 'package:amulet_server/packages/common.dart';
// import 'package:amulet_flutter/isometric/ui/widgets/isometric_builder.dart';
// import 'package:amulet_flutter/isometric/ui/widgets/item_image.dart';
// import 'package:flutter/material.dart';
// import 'package:golden_ratio/constants.dart';
//
//
// class MMOItemImage extends StatelessWidget {
//   final double size;
//   final AmuletItem item;
//   final double scale;
//
//   MMOItemImage({
//     required this.item,
//     required this.size,
//     this.scale = goldenRatio_1381,
//   });
//
//   @override
//   Widget build(BuildContext context) =>
//         IsometricBuilder(
//           builder: (context, isometric) {
//             return MouseRegion(
//                 onEnter: (_){
//                   isometric.amulet.aimTargetItemTypeCurrent.value = item;
//                 },
//                 onExit: (_){
//                   if (isometric.amulet.aimTargetItemTypeCurrent.value != item)
//                     return;
//                   isometric.amulet.aimTargetItemTypeCurrent.value = null;
//                 },
//                 child: ItemImage(
//                   size: size,
//                   type: item.type,
//                   subType: item.subType,
//                   scale: scale,
//                 )
//             );
//           }
//         );
// }
//
//
