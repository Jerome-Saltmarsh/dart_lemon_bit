import 'package:flutter/material.dart';
import 'package:amulet_flutter/isometric/ui/widgets/isometric_builder.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class GSKeyEventHandler extends StatelessWidget {

  final Widget child;

  const GSKeyEventHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) =>
      IsometricBuilder(builder: (context, components) {
        components.engine.disableKeyEventHandler();
        return OnDisposed(
          action: components.engine.enableKeyEventHandler,
          child: child,
        );
      });
}
