class NetworkResponse {
  static const Projectiles = 01;
  static const Game_Event = 02;
  static const Player_Event = 03;
  static const Game_Time = 04;
  static const GameObject = 17;
  static const Environment = 18;
  static const Game_Error = 19;
  static const GameObjects = 23;
  static const Amulet = 32;
  static const Isometric = 33;
  static const Characters = 34;
  static const FPS = 35;
  static const Player = 37;
  static const Scene = 38;
  static const Editor = 39;
  static const Server_Error = 41;
  static const Options = 42;

  static String getName(int value){
    return const {
      Projectiles: 'Projectiles',
      Game_Event: 'Game_Event',
      Player_Event: 'Player_Event',
      Game_Time: 'Game_Time',
      GameObject: 'GameObject',
      Environment: 'Environment',
      Game_Error: 'Game_Error',
      GameObjects: 'GameObjects',
      Amulet: 'Amulet',
      Isometric: 'Isometric',
      Characters: 'Characters',
      FPS: 'FPS',
      Player: 'Player',
      Scene: 'Scene',
      Editor: 'Editor',
      Server_Error: 'Server_Error',
      Options: 'Options',
    } [value] ?? ('unknown_network_response.$value');
  }
}
