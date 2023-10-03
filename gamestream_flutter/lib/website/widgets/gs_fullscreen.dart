import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/ui/widgets/isometric_builder.dart';

class GSFullscreen extends StatelessWidget {
  final Widget child;

  const GSFullscreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) => IsometricBuilder(
      builder: (context, components) => Container(
            width: components.engine.screen.width,
            height: components.engine.screen.height,
            child: child,
          ));
}
