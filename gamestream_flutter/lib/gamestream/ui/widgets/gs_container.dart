
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/game_style.dart';

class GSContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool rounded;
  final Color? color;

  const GSContainer({
    super.key,
    this.child,
    this.alignment = Alignment.center,
    this.color = GS_CONTAINER_COLOR,
    this.width,
    this.height,
    this.rounded = false,
  });

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: GameStyle.Container_Padding,
      child: child,
      decoration: BoxDecoration(
        color: color,
        borderRadius: rounded ? const BorderRadius.all(Radius.circular(4)) : null
      ),
    );
}