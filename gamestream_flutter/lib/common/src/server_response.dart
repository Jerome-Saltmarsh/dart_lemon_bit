class ServerResponse {
  static const Api_Player                 = 00;
  static const Projectiles                = 01;
  static const Game_Event                 = 02;
  static const Player_Event               = 03;
  static const Game_Time                  = 04;
  static const Game_Type                  = 05;
  static const Player_Target              = 07;
  static const Node                       = 09;
  static const Store_Items                = 10;
  static const Weather                    = 11;
  static const Game_Properties            = 12;
  static const Npc_Talk                   = 13;
  static const Map_Coordinate             = 14;
  static const Editor_GameObject_Selected = 16;
  static const GameObject                 = 17;
  static const Environment                = 18;
  static const Game_Error                 = 19;
  static const Download_Scene             = 22;
  static const GameObjects                = 23;
  static const GameObject_Deleted         = 24;
  static const Info                       = 26;
  static const Api_SPR                    = 28;
  static const Fight2D                    = 30;
  static const Capture_The_Flag           = 31;
  static const MMO                        = 32;
  static const Isometric                  = 33;
  static const Isometric_Characters       = 34;
  static const FPS                        = 35;

  static String getName(int value) {
    return <int, String>{
      Api_Player: 'Api_Player',
      Projectiles: 'Projectiles',
      Game_Event: 'Game_Event',
      Player_Event: 'Player_Event',
      Game_Time: 'Game_Time',
      Game_Type: 'Game_Type',
      // End: "End",
      Player_Target: 'Player_Target',
      Node: 'Node',
      Store_Items: 'Store_Items',
      Weather: 'Weather',
      Game_Properties: 'Game_Properties',
      Npc_Talk: 'Npc_Talk',
      Map_Coordinate: 'Map_Coordinate',
      Isometric_Characters: 'Isometric Characters',
      Editor_GameObject_Selected: 'Editor_GameObject_Selected',
      GameObject: 'GameObject',
      Environment: 'Environment',
      Game_Error: 'Game_Error',
      Download_Scene: 'Download_Scene',
      GameObjects: 'GameObjects',
      GameObject_Deleted: 'GameObject_Deleted',
      Info: 'Info',
      Api_SPR: 'Api_SPR',
      Fight2D: 'Fight2D',
      Capture_The_Flag: 'Capture_The_Flag',
      MMO: 'MMO',
      Isometric: 'Isometric',
      FPS: 'FPS',
    }[value] ?? 'server-response-missing-name-$value';
  }
}
