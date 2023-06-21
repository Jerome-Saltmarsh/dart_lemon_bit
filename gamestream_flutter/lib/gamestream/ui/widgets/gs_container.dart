
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/game_style.dart';

class GSContainer extends StatelessWidget {
  final Widget child;

  const GSContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.center,
      color: GameStyle.Container_Color,
      padding: GameStyle.Container_Padding,
      child: child,
    );

}