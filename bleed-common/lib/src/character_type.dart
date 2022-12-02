
class CharacterType {
   static const Template = 0;
   static const Zombie = 1;
   static const Rat = 2;
   static const Slime = 3;
   static const Wolf = 4;
   static const Triangle = 5;

   static double getSpeed(int value) => const {
          Template: 3.0,
          Zombie: 2.5,
          Rat: 1.5,
          Slime: 1.5,
          Wolf: 4.0,
          Triangle: 3.5,
       }[value] ?? 2.0;

   static bool supportsUpperBody(int characterType) {
     return characterType == Template;
   }
}