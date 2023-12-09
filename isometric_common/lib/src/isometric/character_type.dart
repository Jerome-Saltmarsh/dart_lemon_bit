
class CharacterType {
   static const Human = 7;
   static const Fallen = 8;
   static const Skeleton = 9;
   static const Wolf = 10;

   static const values = [
     Human,
     Fallen,
     Skeleton,
     Wolf,
   ];

   static String getName(int value) => const {
       Human: 'Human',
       Fallen: 'Fallen',
       Skeleton: 'Skeleton',
       Wolf: 'Wolf',
   }[value] ?? ' unknown-$value';
}