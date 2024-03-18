//
// import 'package:amulet_client/common/src/isometric/character_state.dart';
//
// class AnimationMode {
//   static const Single = 0;
//   static const Loop = 1;
//   static const Bounce = 2;
//
//   static int fromCharacterState(int characterState) =>
//       switch (characterState){
//         CharacterState.Strike => Single,
//         CharacterState.Fire => Single,
//         CharacterState.Hurt => Single,
//         CharacterState.Running => Loop,
//         CharacterState.Idle => Bounce,
//         CharacterState.Dead => Single,
//         CharacterState.Changing => Single,
//         CharacterState.Aiming => Loop,
//         CharacterState.Spawning => Loop,
//         CharacterState.Stunned => Loop,
//         _ => throw Exception(),
//       };
// }