
import 'package:bleed_client/common/classes/Vector2.dart';

final _Atlas atlas = _Atlas();

class _Atlas {
  final Vector2 myst = Vector2(2410, 1);
  final Vector2 circle = Vector2(2410, 513);

  final _Zombie zombie = _Zombie();
}

class _Zombie {
  final Vector2 striking = Vector2(1, 2463);
}