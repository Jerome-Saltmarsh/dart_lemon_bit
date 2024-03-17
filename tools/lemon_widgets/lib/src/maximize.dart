
import 'package:flutter/material.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget maximize({
  required BuildContext context,
  Widget? child,
  Alignment? alignment,
  Color? color,
}) =>
    Container(
      width: context.width,
      height: context.height,
      alignment: alignment,
      child: child,
      color: color,
    );