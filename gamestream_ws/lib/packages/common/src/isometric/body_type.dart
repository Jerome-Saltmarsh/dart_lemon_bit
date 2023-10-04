class BodyType {
   static const None = 0;
   static const Shirt_Blue = 2;
   static const Leather_Armour = 3;

   static String getName(int value) => const {
         None: 'None',
         Shirt_Blue: 'shirt_blue',
         Leather_Armour: 'leather_armour'
      }[value] ?? 'unknown-body-type-$value';

   static const values = [
      Shirt_Blue,
      Leather_Armour,
   ];
}
