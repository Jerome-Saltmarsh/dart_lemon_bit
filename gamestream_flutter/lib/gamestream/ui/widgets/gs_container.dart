
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';

class GSContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool rounded;
  final Color? color;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const GSContainer({
    super.key,
    this.child,
    this.alignment = Alignment.center,
    this.color = GS_CONTAINER_COLOR,
    this.padding = GS_CONTAINER_PADDING,
    this.width,
    this.height,
    this.margin,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding,
      margin: margin,
      child: child,
      decoration: BoxDecoration(
        color: color,
        borderRadius: rounded ? GS_CONTAINER_BORDER_RADIUS_ROUNDED : null
      ),
    );
}