


// void mapSrcHuman({
//     required SlotType slotType,
//     required CharacterState characterState,
//     required int direction,
//     required int frame
// }) {
//
//   switch (characterState) {
//     case CharacterState.Idle:
//
//       return srcSingle(
//         atlas: _idleWeaponTypeVector2[slotType] ?? atlas.human.unarmed.idle,
//         direction: direction,
//       );
//
//     case CharacterState.Dead:
//       return srcSingle(atlas: atlas.human.dying, direction: direction);
//
//     case CharacterState.Firing:
//       switch (slotType) {
//         case SlotType.Handgun:
//           return srcAnimate(
//               atlas: atlas.human.handgun.firing,
//               animation: animations.human.firingHandgun,
//               direction: direction,
//               frame: frame,
//               framesPerDirection: 2,
//           );
//
//         case SlotType.Shotgun:
//           return srcAnimate(
//             atlas: atlas.human.shotgun.firing,
//             animation: animations.human.firingShotgun,
//             direction: direction,
//             frame: frame,
//             framesPerDirection: 3,
//           );
//
//         default:
//           return srcAnimate(
//             atlas: atlas.human.shotgun.firing,
//             animation: animations.human.firingShotgun,
//             direction: direction,
//             frame: frame,
//             framesPerDirection: 3,
//           );
//       }
//     case CharacterState.Performing:
//       if (slotType == SlotType.Bow_Wooden){
//         return srcAnimate(
//           atlas: atlas.human.striking,
//           animation: animations.human.firingBow,
//           direction: direction,
//           frame: frame,
//           framesPerDirection: 2,
//         );
//       }else{
//         return srcAnimate(
//           atlas: atlas.human.striking,
//           animation: animations.human.strikingSword,
//           direction: direction,
//           frame: frame,
//           framesPerDirection: 2,
//         );
//       }
//
//
//     case CharacterState.Running:
//       switch (slotType) {
//         case SlotType.Handgun:
//           return srcLoop(
//               atlas: atlas.human.handgun.running,
//               direction: direction,
//               frame: frame
//           );
//         case SlotType.Shotgun:
//           return srcLoop(
//               atlas: atlas.human.shotgun.running,
//               direction: direction,
//               frame: frame
//           );
//         case SlotType.Sniper_Rifle:
//           return srcLoop(
//               atlas: atlas.human.shotgun.running,
//               direction: direction,
//               frame: frame
//           );
//         case SlotType.Assault_Rifle:
//           return srcLoop(
//               atlas: atlas.human.shotgun.running,
//               direction: direction,
//               frame: frame
//           );
//         default:
//           return srcLoop(
//             atlas: atlas.human.unarmed.running,
//             direction: direction,
//             frame: frame,
//           );
//       }
//     case CharacterState.Changing:
//       return srcAnimate(
//         atlas: atlas.human.changing,
//         animation: animations.human.changing,
//         direction: direction,
//         frame: frame,
//         framesPerDirection: 2,
//       );
//   }
// }
