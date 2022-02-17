

import 'SlotType.dart';

const Map<SlotType, _SlotTypeCost> slotTypeCosts = {
  SlotType.Sword_Wooden: _SlotTypeCost(
      rubies: 1,
      emeralds: 1,
  ),
  SlotType.Sword_Short: _SlotTypeCost(
    rubies: 4,
    emeralds: 4,
  ),
  SlotType.Sword_Long: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Bow_Wooden: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Bow_Green: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Bow_Gold: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Staff_Wooden: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Staff_Blue: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Staff_Golden: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Spell_Tome_Fireball: _SlotTypeCost(
    rubies: 5,
    emeralds: 3,
  ),
  SlotType.Golden_Necklace: _SlotTypeCost(
    rubies: 3,
    emeralds: 1,
    topaz: 4,
  ),
  SlotType.Silver_Pendant: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Armour_Padded: _SlotTypeCost(
    rubies: 5,
    emeralds: 5,
  ),
  SlotType.Steel_Helmet: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Body_Blue: _SlotTypeCost(
    rubies: 15,
    emeralds: 15,
  ),
  SlotType.Potion_Red: _SlotTypeCost(
    rubies: 1,
    emeralds: 1,
  ),
  SlotType.Potion_Blue: _SlotTypeCost(
    rubies: 1,
    emeralds: 1,
  ),
  SlotType.Rogue_Hood: _SlotTypeCost(
    rubies: 1,
    emeralds: 1,
  ),
  SlotType.Magic_Hat: _SlotTypeCost(
    rubies: 1,
    emeralds: 1,
  ),
  SlotType.Magic_Robes: _SlotTypeCost(
    rubies: 1,
    emeralds: 1,
  ),
};

const Map<SlotType, String> slotTypeNames = {
  SlotType.Golden_Necklace: "King's Necklace",
  SlotType.Sword_Wooden: "Wooden Sword",
  SlotType.Sword_Short: "Steel Sword",
  SlotType.Sword_Long: "Iron Sword",
  SlotType.Bow_Wooden: "Wooden Bow",
  SlotType.Bow_Gold: "Golden Bow",
  SlotType.Bow_Green: "Forest Bow",
  SlotType.Staff_Wooden: "Gnarled Staff",
  SlotType.Staff_Blue: "Sapphire Staff",
  SlotType.Staff_Golden: "Golden Staff",
  SlotType.Spell_Tome_Fireball: "Learn Fireball 1",
  SlotType.Steel_Helmet: "Knight's Helm",
  SlotType.Armour_Padded: "Padded Armour",
  SlotType.Body_Blue: "Steel Tunic",
  SlotType.Potion_Red: "Health Potion",
  SlotType.Rogue_Hood: "Rogue's Hood",
  SlotType.Potion_Blue: "Magic Potion",
  SlotType.Magic_Hat: "Wizards Hat",
  SlotType.Magic_Robes: "Robes of Magic",
};

class _SlotTypeCost {
  final int topaz;
  final int rubies;
  final int emeralds;
  const _SlotTypeCost({
    this.topaz = 0,
    this.rubies = 0,
    this.emeralds = 0
  });
}