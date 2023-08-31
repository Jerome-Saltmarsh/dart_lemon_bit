
class TargetAction {
   static const Talk       = 1;
   static const Attack     = 2;
   static const Run        = 3;
   static const Collect    = 4;

   static String getName(int value) => const {
      Talk: 'Talk',
      Attack: 'Attack',
      Run      : 'Run',
      Collect  : 'Collect',
   }[value] ?? 'target-category-unknown($value)';
}