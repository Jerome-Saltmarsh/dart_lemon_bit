
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/ui/constants/game_style.dart';

class GSContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const GSContainer({super.key, required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) => Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: GameStyle.Container_Color,
      padding: GameStyle.Container_Padding,
      child: child,
    );

}