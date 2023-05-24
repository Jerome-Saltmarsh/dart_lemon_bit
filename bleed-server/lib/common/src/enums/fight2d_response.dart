
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
   static const Jumping_Strike   = 5;
   static const Strike_Up        = 6;
   static const Falling          = 7;
   static const Crouching        = 8;
   static const Hurting          = 9;
   static const Hurting_Airborn  = 10;
   static const Falling_Down     = 11;

   static String getName(int value) =>
      const {
        Idle: 'Idle',
        Running: 'Running',
        Striking: 'Striking',
        Jumping: 'Jumping',
        Running_Strike: 'Running_Strike',
        Jumping_Strike: 'Jumping_Strike',
        Falling: 'Falling',
        Crouching: 'Crouching',
        Strike_Up: 'Strike_Up',
        Hurting: 'Hurting',
        Hurting_Airborn: 'Hurting_Airborn',
      }[value] ??
      'unknown';


   // static int getOutputState(int currentState, int inputState){
   //   switch (currentState){
   //     case Idle:
   //       return 0;
   //     case Running:
   //       return switch
   //   }
   //
   //   return 0;
   // }
}