
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric_components.dart';
import 'package:provider/provider.dart';

class IsometricBuilder extends StatelessWidget {

  final Widget Function(BuildContext context, IsometricComponents isometric) builder;

  IsometricBuilder({required this.builder});

  @override
  Widget build(BuildContext context) =>
      builder(context, Provider.of<IsometricComponents>(context));
}
