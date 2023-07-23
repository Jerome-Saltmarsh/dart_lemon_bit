
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/ui/isometric_builder.dart';

class StackFullscreen extends StatelessWidget {

  final List<Widget> children;

  StackFullscreen({required this.children});

  @override
  Widget build(BuildContext context) =>
    IsometricBuilder(
      builder: (context, isometric) => Container(
            width: isometric.engine.screen.width,
            height: isometric.engine.screen.height,
            child: Stack(children:children)
        )
    );


}