
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/library.dart';

class StackFullscreen extends StatelessWidget {

  final List<Widget> children;

  StackFullscreen({required this.children});

  @override
  Widget build(BuildContext context) =>
    Container(
        width: Engine.screen.width,
        height: Engine.screen.height,
        child: Stack(children:children)
    );


}