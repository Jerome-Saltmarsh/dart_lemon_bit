
class CharacterType {
   static const Human = 7;
   static const Fallen = 8;
   static const Skeleton = 9;

   static const values = [
     Human,
     Fallen,
     Skeleton,
   ];

   static String getName(int value) => const {
       Human: 'Human',
       Fallen: 'Fallen',
       Skeleton: 'Skeleton',
   }[value] ?? ' unknown-$value';
}