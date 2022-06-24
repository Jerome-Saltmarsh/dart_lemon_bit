
class PantsType {
   static const brown = 0;
   static const blue = 1;
   static const red = 2;
   static const green = 3;
   static const white = 4;

   static String getName(int type){
      return <int, String> {
         brown: "Brown",
         blue: "Blue",
         red: "Red",
         green: "Green",
         white: "White",
      }[type]!;
   }
   
   static const values = [
      brown,
      blue,
      red,
      green,
      white,
   ];
}