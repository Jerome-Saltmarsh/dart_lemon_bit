
enum MMOTalentType {
   Treasure_Slots(description: 'Unlock Treasure Slot', maxLevel: 3, levelCostMultiplier: 2),
   Ability_Slots (description: 'Unlock Ability Slot', maxLevel: 2),
   Healthy (description: 'Increase Max Health', maxLevel: 5),
   Vampire (description: 'Gain health on each attack', maxLevel: 2),
   Bow_Master (description: 'Increase Bow Damage', maxLevel: 10),
   Warrior_Master (description: 'Increase Melee Damage', maxLevel: 10),
   Sorcerer_Master (description: 'Increase Magic Damage', maxLevel: 10),
   Speedy (description: 'Increase run speed', maxLevel: 3),
   Lucky (description: 'Increase chance of doing double damage', maxLevel: 3);

   final String description;

   final int maxLevel;

   final int levelCostMultiplier;

   const MMOTalentType({
      required this.description,
      this.maxLevel = 1,
      this.levelCostMultiplier = 1,
   });
}