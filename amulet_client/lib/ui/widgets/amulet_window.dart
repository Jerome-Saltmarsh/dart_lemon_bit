
import 'package:amulet_client/ui/isometric_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class AmuletWindow extends StatelessWidget {
  final Widget child;

  const AmuletWindow({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
      color: Palette.brown_4,
      padding: paddingAll8,
      child: child,
    );
}