
class TargetCategory {
   static const Nothing    = 0;
   static const Allie      = 1;
   static const Enemy      = 2;
   static const Run        = 3;
   static const Collect    = 4;
   static const Interact   = 5;

   static String getName(int value) => const {
      Nothing  : "Nothing",
      Allie    : "Allie",
      Enemy    : "Enemy",
      Collect  : "Collect",
      Run      : "Run",
      Interact : "Interact",
   }[value] ?? "target-category-unknown($value)";
}