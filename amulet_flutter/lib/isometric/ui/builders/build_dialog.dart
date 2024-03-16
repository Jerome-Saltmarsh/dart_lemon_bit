// import 'package:amulet_flutter/isometric/consts/border_radius.dart';
// import 'package:flutter/material.dart';
// import 'package:amulet_flutter/isometric/ui/widgets/isometric_builder.dart';
//
// Widget buildDialog({
//   required Widget child,
//   double padding = 8,
//   double width = 400,
//   double height = 600,
//   Color color = Colors.white24,
//   Color borderColor = Colors.white,
//   double borderWidth = 2,
//   BorderRadius borderRadius = borderRadius4,
//   Alignment alignment = Alignment.center,
//   EdgeInsets margin = EdgeInsets.zero,
// }) {
//   return IsometricBuilder(
//     builder: (context, isometric) {
//       return Container(
//         width: isometric.engine.screen.width,
//         height: isometric.engine.screen.height,
//         alignment: alignment,
//         child: Container(
//           margin: margin,
//           decoration: BoxDecoration(
//               border: Border.all(color: borderColor, width: borderWidth),
//               borderRadius: borderRadius,
//               color: color),
//           padding: EdgeInsets.all(padding),
//           width: width,
//           height: height,
//           child: child,
//         ),
//       );
//     }
//   );
// }
