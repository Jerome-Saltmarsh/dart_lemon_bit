

class PerkType {
   static const Max_Health = 0;
   static const Damage = 1;

   static const values = [
     Max_Health,
     Damage,
   ];

   static String getName(int value) => const {
         Max_Health: "Max Health",
         Damage: "Damage",
      }[value] ?? 'character-perk-unknown($value)';
}