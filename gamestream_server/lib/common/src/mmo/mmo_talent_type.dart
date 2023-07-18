
enum MMOTalentType {
   Treasure_Slots_1,
   Treasure_Slots_2 (parent: Treasure_Slots_1),
   Treasure_Slots_3 (parent: Treasure_Slots_2),
   Ability_Slots_1,
   Ability_Slots_2 (parent: Ability_Slots_1),
   Ability_Slots_3 (parent: Ability_Slots_2),
   Healthy_1,
   Healthy_2 (parent: Healthy_1),
   Healthy_3 (parent: Healthy_2),
   Vampire_1,
   Vampire_2 (parent: Vampire_1),
   Bow_Master_1,
   Bow_Master_2 (parent: Bow_Master_1),
   Bow_Master_3 (parent: Bow_Master_2),
   Warrior_Master_1,
   Warrior_Master_2 (parent: Warrior_Master_1),
   Warrior_Master_3 (parent: Warrior_Master_2),
   Sorcerer_Master_1,
   Sorcerer_Master_2 (parent: Sorcerer_Master_1),
   Sorcerer_Master_3 (parent: Sorcerer_Master_2),
   Speedy_1,
   Speedy_2 (parent: Speedy_1);

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

   const MMOTalentType({this.parent});

   static final rootValues = values.where((element) => element.parent == null).toList(growable: false);
}