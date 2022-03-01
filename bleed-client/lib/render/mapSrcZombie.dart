




// void mapSrcZombie({
//   required CharacterState state,
//   required int direction,
//   required int shade,
//   required int frame
// }) {
//   switch (state) {
//     case CharacterState.Idle:
//         return srcLoop(
//             atlas: atlas.zombie.idle,
//             direction: direction,
//             shade: shade,
//             framesPerDirection: 1,
//             frame: frame
//         );
//
//     case CharacterState.Running:
//       return srcLoop(
//           atlas: atlas.zombie.running,
//           direction: direction,
//           shade: shade,
//           framesPerDirection: 4,
//           frame: frame
//       );
//
//     case CharacterState.Performing:
//       return srcLoop(
//           atlas: atlas.zombie.striking,
//           direction: direction,
//           shade: shade,
//           framesPerDirection: 2,
//           frame: frame
//       );
//   }
//
//   throw Exception("Could not map zombie");
// }