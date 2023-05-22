
class Fight2DResponse {
   static const Characters = 0;
   static const Scene      = 1;
   static const Player     = 2;
}

class GameFight2DCharacterState {
   static const Idle_Left      = 0;
   static const Run_Left       = 1;
   static const Strike_Left    = 2;
   static const Jump_Left      = 3;

   static const Idle_Right     = 4;
   static const Run_Right      = 5;
   static const Jump_Right     = 6;
   static const Strike_Right   = 7;

   static String getName(int value) => const {
         Idle_Left: 'Idle_Left',
         Run_Left: 'Run_Left',
         Strike_Left: 'Strike_Left',
         Jump_Left: 'Jump_Left',
         Idle_Right: 'Idle_Right',
         Run_Right: 'Run_Right',
         Jump_Right: 'Jump_Right',
         Strike_Right: 'Strike_Right',
      }[value] ?? 'unknown';

   static bool isLeft(int value){
      return value <= Jump_Left;
   }
}