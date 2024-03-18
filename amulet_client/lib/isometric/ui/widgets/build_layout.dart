//
// import 'package:flutter/material.dart';
// import 'build_fullscreen.dart';
//
//
//
// Widget buildLayout({
//   bool expand = true,
//   Widget? topLeft,
//   Widget? topRight,
//   Widget? bottomRight,
//   Widget? bottomLeft,
//   Widget? top,
//   List<Widget>? children,
//   Widget? child,
//   double padding = 0,
//   Color? color,
//   Widget? foreground,
// }){
//   final stack = Stack(
//     children: [
//       if (children != null)
//         ...children,
//       if (child != null)
//         child,
//       if (topLeft != null)
//         Positioned(top: padding, left: padding, child: topLeft,),
//       if (topRight != null)
//         Positioned(top: padding, right: padding, child: topRight,),
//       if (bottomRight != null)
//         Positioned(bottom: padding, right: padding, child: bottomRight,),
//       if (bottomLeft != null)
//         Positioned(bottom: padding, left: padding, child: bottomLeft,),
//       if (top != null)
//         Positioned(top: padding, child: top),
//       if (foreground != null)
//         foreground,
//     ],
//   );
//   return expand ? buildFullScreen(child: stack, color: color): stack;
// }
//
