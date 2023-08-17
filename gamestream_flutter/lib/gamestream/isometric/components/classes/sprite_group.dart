import 'package:gamestream_flutter/common/src/isometric/character_state.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/sprite.dart';

class SpriteGroup {
  final Sprite idle;
  final Sprite running;
  final Sprite strike;
  final Sprite hurt;
  final Sprite dead;
  final Sprite fire;
  final Sprite change;

  SpriteGroup({
    required this.idle,
    required this.running,
    required this.strike,
    required this.hurt,
    required this.dead,
    required this.fire,
    required this.change,
  });

  Sprite fromCharacterState(int characterState) =>
    switch (characterState) {
      CharacterState.Idle => idle,
      CharacterState.Running => running,
      CharacterState.Strike => strike,
      CharacterState.Hurt => hurt,
      CharacterState.Dead => dead,
      CharacterState.Fire => fire,
      CharacterState.Changing => change,
      _ => throw Exception(),
    };
}
