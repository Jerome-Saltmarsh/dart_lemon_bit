

import 'SlotType.dart';

final Map<SlotType, _SlotTypeCost> slotTypeCosts = {
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
};

final Map<SlotType, String> slotTypeNames = {
  SlotType.Sword_Wooden: "Wooden Sword",
  SlotType.Sword_Short: "Steel Sword",
  SlotType.Sword_Long: "Iron Sword",
  SlotType.Bow_Wooden: "Wooden Bow",
  SlotType.Bow_Gold: "Golden Bow",
  SlotType.Bow_Green: "Forest Bow",
  SlotType.Staff_Wooden: "Gnarled Staff",
  SlotType.Staff_Blue: "Sapphire Staff",
  SlotType.Staff_Golden: "Golden Staff",
};

class _SlotTypeCost {
  final int topaz;
  final int rubies;
  final int emeralds;
  _SlotTypeCost({
    this.topaz = 0,
    this.rubies = 0,
    this.emeralds = 0
  });
}