
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/game_style.dart';

class GSContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool rounded;

  const GSContainer({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
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
        color: GameStyle.Container_Color,
        borderRadius: rounded ? const BorderRadius.all(Radius.circular(4)) : null
      ),
    );
}