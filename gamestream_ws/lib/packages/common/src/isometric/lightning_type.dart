
class LightningType {
   static const Off = 0;
   static const Nearby = 1;
   static const On = 2;

   static const values = [Off, Nearby, On];

   static String getName(int value) => const {
         Off: 'Off',
         Nearby:'Nearby',
         On: 'On'
   }[value] ?? 'unknown-lightning-$value';
}
