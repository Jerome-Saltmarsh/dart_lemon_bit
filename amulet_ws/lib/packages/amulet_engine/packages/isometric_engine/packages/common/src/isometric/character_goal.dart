class CharacterGoal {
 static const Idle = 0;
 static const Kill_Target = 1;
 static const Interact_With_Target = 2;
 static const Collect_Target = 3;
 static const Roam = 4;
 static const Follow_Path = 5;
 static const Run_To_Destination = 6;
 static const Wander = 7;
 static const Force_Attack = 8;

 static String getName(int value) => const {
  Idle: 'Idle',
  Kill_Target: 'Kill Target',
  Interact_With_Target: 'Interact With Target',
  Collect_Target: 'Collect Target',
  Roam: 'Roam',
  Follow_Path: 'Follow Path',
  Run_To_Destination: 'Run to Destination',
  Wander: 'Wander',
  Force_Attack: 'Force_Shot'
 }[value] ?? 'unknown-$value';
}
