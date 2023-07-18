
enum MMOTalentType {
   Treasure_Slots_1(description: 'Unlock Treasure Slot 2'),
   Treasure_Slots_2 (description: 'Unlock Treasure Slot 3', parent: Treasure_Slots_1),
   Treasure_Slots_3 (description: 'Unlock Treasure Slot 4', parent: Treasure_Slots_2),
   Ability_Slots_1 (description: 'Unlock Ability Slot 2'),
   Ability_Slots_2 (description: 'Unlock Ability Slot 3', parent: Ability_Slots_1),
   Ability_Slots_3 (description: 'Unlock Ability Slot 4', parent: Ability_Slots_2),
   Healthy_1 (description: 'Increase Health by 10'),
   Healthy_2 (description: 'Increase Health by 15', parent: Healthy_1),
   Healthy_3 (description: 'Increase Health by 20', parent: Healthy_2),
   Vampire_1 (description: 'Steal 1 health each attack'),
   Vampire_2 (description: 'Steal 2 health each attack', parent: Vampire_1),
   Bow_Master_1 (description: 'Bow Attacks deal 2 more damage'),
   Bow_Master_2 (description: 'Bow Attacks deal 5 more damage', parent: Bow_Master_1),
   Bow_Master_3 (description: 'Bow Attacks deal 7 more damage', parent: Bow_Master_2),
   Warrior_Master_1 (description: 'Melee Attacks deal 2 more damage'),
   Warrior_Master_2 (description: 'Melee Attacks deal 4 more damage', parent: Warrior_Master_1),
   Warrior_Master_3 (description: 'Melee Attacks deal 6 more damage', parent: Warrior_Master_2),
   Sorcerer_Master_1 (description: 'Magic Attacks deal 2 more damage'),
   Sorcerer_Master_2 (description: 'Melee Attacks deal 4 more damage', parent: Sorcerer_Master_1),
   Sorcerer_Master_3 (description: 'Melee Attacks deal 6 more damage', parent: Sorcerer_Master_2),
   Speedy_1 (description: 'run speed increased by 1'),
   Speedy_2 (description: 'run speed increased by 1', parent: Speedy_1),
   Lucky_1 (description: '5% chance of double damage'),
   Lucky_2 (description: '10% chance of double damage', parent: Lucky_1),
   Lucky_3 (description: '20% chance of double damage', parent: Lucky_2);

   MMOTalentType? get child {
      for (final talent in values){
          if (talent.parent == this)
             return talent;
      }
     return null;
   }

   List<MMOTalentType> get children {
      final children = <MMOTalentType>[];

      var current = this;
      children.add(this);

      while (current.child != null){
         final child = current.child;

         if (child == null)
            return children;

         children.add(child);
         current = child;
      }
      return children;
   }

   final MMOTalentType? parent;

   final String description;

   const MMOTalentType({this.parent, required this.description});

   static final rootValues = values.where((element) => element.parent == null).toList(growable: false);
}