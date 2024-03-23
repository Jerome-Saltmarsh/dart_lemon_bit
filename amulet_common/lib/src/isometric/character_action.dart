//
//
// class CharacterAction {
//   static const Idle = 0;
//   static const Attack_Target = 1;
//   static const Follow_Path = 2;
//   static const Run_To_Destination = 3;
//   static const Run_To_Target = 4;
//   static const Interact_Target = 5;
//   static const Collect_Target = 6;
//   static const Dead = 7;
//   static const Busy = 8;
//   static const Attacking = 9;
//   static const Stuck = 10;
//
//   static String getName(int value) => {
//       Idle: 'Idle',
//       Attack_Target: 'Idle',
//       Follow_Path: 'Follow Path',
//       Run_To_Destination: 'Run To Destination',
//       Run_To_Target: 'Run To Target',
//       Interact_Target: 'Interact Target',
//       Collect_Target: 'Collect Target',
//       Dead: 'Dead',
//       Busy: 'Busy',
//       Attacking: 'Attacking',
//       Stuck: 'Stuck',
//     }[value] ?? 'unknown-character-action-$value';
// }