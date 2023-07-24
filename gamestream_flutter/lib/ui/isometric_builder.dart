
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:provider/provider.dart';

class IsometricBuilder extends StatelessWidget {

  final Widget Function(BuildContext context, Isometric isometric) builder;

  IsometricBuilder({required this.builder});

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<Isometric>(context));
}
