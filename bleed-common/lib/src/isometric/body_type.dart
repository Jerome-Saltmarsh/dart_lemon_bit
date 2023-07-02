class BodyType {
   static const Nothing = 0;
   static const Shirt_Red = 1;
   static const Shirt_Blue = 2;
   static const Shirt_Cyan = 3;
   static const Swat = 4;
   static const Tunic_Padded = 5;

   static String getName(int value) {
      return const {
         Nothing: "Nothing",
         Shirt_Red: "Red Shirt",
         Shirt_Blue: "Blue Shirt",
         Shirt_Cyan: "Cyan Shirt",
         Swat: "Swat",
         Tunic_Padded: "Padded Tunic",
      }[value] ?? 'unknown-body-type-$value';
   }

   static const values = [
      Nothing,
      Shirt_Red,
      Shirt_Blue,
      Shirt_Cyan,
      Swat,
      Tunic_Padded,
   ];
}
