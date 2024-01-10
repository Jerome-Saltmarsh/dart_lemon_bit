
class CharacterType {
   static const Human = 7;
   static const Fallen = 8;
   static const Skeleton = 9;
   static const Wolf = 10;
   static const Zombie = 11;
   static const Fallen_Armoured = 12;
   static const Gargoyle_01 = 13;
   static const Toad_Warrior = 14;
   static const Witch_Stone = 15;
   static const Witch_Water = 16;
   static const Witch_Fire = 17;
   static const Witch_Air = 18;

   static const values = [
     Human,
     Fallen,
     Skeleton,
     Wolf,
     Zombie,
     Fallen_Armoured,
     Gargoyle_01,
     Toad_Warrior,
   ];

   static String getName(int value) => const {
       Human: 'Human',
       Fallen: 'Fallen',
       Skeleton: 'Skeleton',
       Wolf: 'Wolf',
       Zombie: 'Zombie',
       Fallen_Armoured: 'Fallen_Armoured',
       Gargoyle_01: 'Gargoyle_01',
       Toad_Warrior: 'Toad_Warrior',
   }[value] ?? ' unknown-$value';
}