
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget maximize({
  Widget? child,
  Alignment? alignment,
  Color? color,
}) =>
    Builder(
        builder: (context) => Container(
              width: context.width,
              height: context.height,
              alignment: alignment,
              child: child,
              color: color,
            ));