import 'package:flutter/material.dart';
import 'package:amulet_flutter/isometric/ui/widgets/isometric_builder.dart';

Widget buildFullScreen({
  required Widget child,
  Alignment alignment = Alignment.center,
  Color? color,
}) =>
    IsometricBuilder(
      builder: (context, isometric) => Container(
          width: isometric.engine.screen.width,
          height: isometric.engine.screen.height,
          alignment: alignment,
          child: child,
          color: color,
        )
    );