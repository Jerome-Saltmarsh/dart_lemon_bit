import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:provider/provider.dart';


class IsometricProvider extends StatelessWidget {

  final Isometric isometric;

  IsometricProvider(this.isometric);

  @override
  Widget build(BuildContext context) => Provider<Isometric>(
      create: (context) => isometric,
      child: isometric,
    );
}