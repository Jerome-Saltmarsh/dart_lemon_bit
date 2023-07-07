

class CharacterAction {
  static const Idle = 0;
  static const Attack_Target = 1;
  static const Follow_Path = 2;
  static const Run_To_Destination = 3;

  static String getName(int value) => {
      Idle: "Idle",
      Attack_Target: "Idle",
      Follow_Path: "Follow_Path",
      Run_To_Destination: "Run_To_Destination",
    }[value] ?? 'unknown-charcter-action-$value';
}