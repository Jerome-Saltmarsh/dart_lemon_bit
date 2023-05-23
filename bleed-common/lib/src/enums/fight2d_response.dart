
class Fight2DResponse {
   static const Characters = 0;
   static const Scene      = 1;
   static const Player     = 2;
}

class GameFight2DDirection {
  static const Left = 0;
  static const Right = 1;
}

class GameFight2DCharacterState {
   static const Idle             = 0;
   static const Running          = 1;
   static const Striking         = 2;
   static const Jumping          = 3;
   static const Running_Strike   = 4;

   static String getName(int value) =>
      const {
        Idle: 'Idle',
        Running: 'Running',
        Striking: 'Striking',
        Jumping: 'Jumping',
        Running_Strike: 'Running_Strike',
      }[value] ??
      'unknown';
}