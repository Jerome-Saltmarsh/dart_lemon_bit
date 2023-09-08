
class CharacterType {
   static const Kid = 7;
   static const Fallen = 8;
   static const Skeleton = 9;

   static const values = [
     Kid,
     Fallen,
     Skeleton,
   ];
   
   static String getName(int value){
     return const {
       Kid: 'Kid',
       Fallen: 'Fallen',
       Skeleton: 'Skeleton',
     }[value] ?? ' unknown-$value';
   }

   static double getSpeed(int value) => const {
          Kid:        3.0,
          Fallen:        2.0,
       }[value] ??    2.0;
   
   static double getRadius(int value) => const {
          Kid:        10.0,
       }[value] ??    10.0;
}