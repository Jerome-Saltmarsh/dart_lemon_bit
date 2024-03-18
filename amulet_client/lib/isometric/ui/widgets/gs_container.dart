
import 'package:amulet_client/isometric/ui/isometric_colors.dart';
import 'package:flutter/cupertino.dart';

class GSContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool rounded;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Border? border;
  final BoxConstraints? constraints;

  GSContainer({
    super.key,
    this.child,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.margin,
    this.color,
    this.padding,
    this.border,
    this.constraints,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) =>
      Container(
        width: width,
        height: height,
        alignment: alignment,
        padding: padding ?? const EdgeInsets.all(16),
        margin: margin,
        child: child,
        constraints: constraints,
        decoration: BoxDecoration(
          color: color ?? Palette.brownDark,
          borderRadius: rounded ? const BorderRadius.all(Radius.circular(4)) : null,
          border: border,
        ),
      );
}