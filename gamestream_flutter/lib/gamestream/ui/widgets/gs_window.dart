
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';

class GSWindow extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  GSWindow({required this.child, this.width, this.height});

  @override
  Widget build(BuildContext context) =>
      GSDialog(child: GSContainer(child: child, width: width, height: height));
}