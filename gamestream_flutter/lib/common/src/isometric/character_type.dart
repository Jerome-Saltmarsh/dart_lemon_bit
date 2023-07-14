
class CharacterType {
   static const Template = 0;
   static const Zombie = 1;
   static const Rat = 2;
   static const Slime = 3;
   static const Wolf = 4;
   static const Triangle = 5;
   static const Dog = 6;

   static const values = [
     Template,
     Zombie,
     Rat,
     Slime,
     Wolf,
     Triangle,
     Dog,
   ];
   
   static String getName(int value){
     return const {
       Template: 'Template',
       Zombie: 'Zombie',
       Rat: 'Rat',
       Slime: 'Slime',
       Wolf: 'Wolf',
       Triangle: 'Triangle',
       Dog: 'Dog',
     }[value] ?? ' unknown-$value';
   }

   static double getSpeed(int value) => const {
          Template:   3.0,
          Zombie:     2.5,
          Rat:        1.5,
          Slime:      1.5,
          Wolf:       4.0,
          Triangle:   3.5,
          Dog:        4.0,
       }[value] ??    2.0;
   
   static double getRadius(int value) => const {
          Template:   14.0,
          Zombie:     14.0,
          Rat:        10.0,
          Slime:      10.0,
          Wolf:       10.0,
          Triangle:   10.0,
          Dog:        10.0,
       }[value] ??    10.0;

   static bool supportsUpperBody(int characterType) =>
       characterType == Template;
}