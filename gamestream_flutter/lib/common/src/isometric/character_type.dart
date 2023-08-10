
class CharacterType {
   static const Template = 0;
   static const Zombie = 1;
   static const Rat = 2;
   static const Slime = 3;
   static const Wolf = 4;
   static const Dog = 6;
   static const Kid = 7;
   static const Fallen = 8;

   static const values = [
     Template,
     Zombie,
     Rat,
     Slime,
     Wolf,
     Dog,
     Kid,
     Fallen,
   ];
   
   static String getName(int value){
     return const {
       Template: 'Template',
       Zombie: 'Zombie',
       Rat: 'Rat',
       Slime: 'Slime',
       Wolf: 'Wolf',
       Dog: 'Dog',
       Kid: 'Kid',
       Fallen: 'Fallen',
     }[value] ?? ' unknown-$value';
   }

   static double getSpeed(int value) => const {
          Template:   3.0,
          Zombie:     2.5,
          Rat:        1.5,
          Slime:      1.5,
          Wolf:       4.0,
          Dog:        4.0,
          Kid:        3.0,
          Fallen:        2.0,
       }[value] ??    2.0;
   
   static double getRadius(int value) => const {
          Template:   14.0,
          Zombie:     14.0,
          Rat:        10.0,
          Slime:      10.0,
          Wolf:       10.0,
          Dog:        10.0,
          Kid:        10.0,
       }[value] ??    10.0;

   static bool supportsUpperBody(int characterType) =>
       characterType == Template;
}