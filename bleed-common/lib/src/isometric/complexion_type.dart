
class ComplexionType {
   static const Fair = 0;
   static const Dark = 1;

   static String getName(int value) => const {
       Fair: 'fair',
       Dark: 'dark',
     }[value] ?? (throw Exception());
}