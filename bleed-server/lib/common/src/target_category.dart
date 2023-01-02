
class TargetCategory {
   static const Nothing = 0;
   static const Allie = 1;
   static const Enemy = 2;
   static const GameObject = 3;
   static const Item = 4;
   static const Run = 5;
   static const Interact = 6;

   static String getName(int value) => const {
      Nothing: "Nothing",
      Allie: "Allie",
      Enemy: "Enemy",
      GameObject: "GameObject",
      Item: "Item",
      Run: "Run",
      Interact: "Interact",
   }[value] ?? "target-category-unknown($value)";
}