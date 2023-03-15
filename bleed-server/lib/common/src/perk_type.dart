

class PerkType {
   static const Extra_Health  = 0;
   static const Extra_Energy  = 1;
   static const Run_Faster    = 2;

   static String getName(int value) => const {
     Extra_Health: "Max Health",
     Extra_Energy: "Damage",
     Run_Faster: "Run Faster",
      }[value] ?? 'character-perk-unknown($value)';
}