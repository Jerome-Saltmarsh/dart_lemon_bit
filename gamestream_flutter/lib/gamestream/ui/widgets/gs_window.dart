
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/ui.dart';

class GSWindow extends StatelessWidget {
  final Widget child;

  GSWindow({required this.child});

  @override
  Widget build(BuildContext context) =>
      GSDialog(child: GSContainer(child: child));
}