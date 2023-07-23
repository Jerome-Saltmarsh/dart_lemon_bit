
import 'package:flutter/cupertino.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:provider/provider.dart';

// todo remove global instance
final gamestream = Isometric();

class IsometricProvider extends StatelessWidget {

  final Isometric isometric;

  IsometricProvider(this.isometric);

  @override
  Widget build(BuildContext context) {
    // final isometric = Isometric();
    return Provider<Isometric>(
      create: (context) => isometric,
      child: isometric,
    );
  }
}