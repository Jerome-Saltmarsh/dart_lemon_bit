
import 'package:gamestream_flutter/common/src/isometric/character_state.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/render/classes/sprite2.dart';

class SpriteGroup2 {
  final Sprite2 idle;
  final Sprite2 running;
  final Sprite2 change;
  final Sprite2 dead;
  final Sprite2 fire;
  final Sprite2 strike;
  final Sprite2 hurt;

  SpriteGroup2({
    required this.idle,
    required this.running,
    required this.change,
    required this.dead,
    required this.fire,
    required this.strike,
    required this.hurt,
  });

  Sprite2 fromCharacterState(int characterState) =>
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