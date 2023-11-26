
import 'package:flutter/cupertino.dart';
import 'package:amulet_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';

class GSContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool rounded;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  GSContainer({
    super.key,
    this.child,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.margin,
    this.color,
    this.padding,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) => IsometricBuilder(
    builder: (context, isometric) {
      return Container(
          width: width,
          height: height,
          alignment: alignment,
          padding: padding ?? isometric.style.containerPadding,
          margin: margin,
          child: child,
          decoration: BoxDecoration(
            color: color ?? isometric.style.containerColor,
            borderRadius: rounded ? isometric.style.containerBorderRadiusCircular : null
          ),
        );
    }
  );
}