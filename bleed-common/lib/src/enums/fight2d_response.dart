
class Fight2DResponse {
   static const Characters = 0;
   static const Scene      = 1;
   static const Player     = 2;
   static const Event      = 3;
}

class GameFight2DDirection {
  static const Left = 0;
  static const Right = 1;
}

class GameFight2DCharacterState {
   static const Idle                = 0;
   static const Running             = 1;
   static const Striking            = 2;
   static const Jumping             = 3;
   static const Running_Strike      = 4;
   static const Airborn_Strike      = 5;
   static const Striking_Up         = 6;
   static const Airborn_Movement    = 7;
   static const Crouching           = 8;
   static const Hurting             = 9;
   static const Hurting_Airborn     = 10;
   static const Idle_Airborn        = 11;
   static const Second_Jump         = 13;
   static const Airborn_Strike_Down = 14;
   static const Airborn_Strike_Up   = 15;
   static const Fall_Fast           = 16;
   static const Crouching_Strike       = 17;

   
   static String getName(int value) =>
      const {
        Idle: 'Idle',
        Running: 'Running',
        Striking: 'Striking',
        Jumping: 'Jumping',
        Running_Strike: 'Running_Strike',
        Airborn_Strike: 'Jumping_Strike',
        Airborn_Movement: 'Falling',
        Crouching: 'Crouching',
        Striking_Up: 'Strike_Up',
        Hurting: 'Hurting',
        Hurting_Airborn: 'Hurting_Airborn',
        Idle_Airborn: "Idle_Airborn",
        Second_Jump: "Second_Jump",
        Airborn_Strike_Down: "Airborn_Strike_Down",
        Airborn_Strike_Up: "Airborn_Strike_Up",
        Crouching_Strike: "Crouching_Strike",
      }[value] ??
      'unknown';
}