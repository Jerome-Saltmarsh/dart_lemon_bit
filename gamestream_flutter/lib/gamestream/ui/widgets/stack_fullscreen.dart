
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

class StackFullscreen extends StatelessWidget {

  final List<Widget> children;

  StackFullscreen({required this.children});

  @override
  Widget build(BuildContext context) =>
    Container(
        width: gamestream.engine.screen.width,
        height: gamestream.engine.screen.height,
        child: Stack(children:children)
    );


}