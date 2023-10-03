import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';

class GSFullscreen extends StatelessWidget {
  final Widget child;
  final Alignment? alignment;

  const GSFullscreen({super.key, required this.child, this.alignment});

  @override
  Widget build(BuildContext context) => IsometricBuilder(
      builder: (context, components) => Container(
            width: components.engine.screen.width,
            height: components.engine.screen.height,
            alignment: alignment,
            child: child,
          ));
}
