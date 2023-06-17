
import 'dart:math';

import 'package:bleed_server/common/src/api_player.dart';
import 'package:bleed_server/common/src/api_players.dart';
import 'package:bleed_server/common/src/enums/item_group.dart';
import 'package:bleed_server/common/src/item_type.dart';
import 'package:bleed_server/common/src/power_type.dart';
import 'package:bleed_server/common/src/server_response.dart';
import 'package:bleed_server/src/games/isometric/isometric_player.dart';

import 'game_combat.dart';

class CombatPlayer extends IsometricPlayer {

  var powerCooldown = 0;
  var weaponPrimary = ItemType.Empty;
  var weaponSecondary = ItemType.Empty;
  var weaponTertiary = ItemType.Empty;

  var _powerType = PowerType.None;
  var _credits = 0;

  final GameCombat game;

  CombatPlayer(this.game) : super(game: game);

  bool get weaponPrimaryEquipped => weaponType == weaponPrimary;
  bool get weaponSecondaryEquipped => weaponType == weaponSecondary;

  int get score => _credits;
  int get powerType => _powerType;

  set powerType(int value) {
    if (_powerType == value) return;
    assert (PowerType.values.contains(value));
    if (!PowerType.values.contains(value)) return;
    _powerType = value;
    writePlayerPower();
  }

  set score(int value) {
    if (_credits == value) return;
    _credits = max(value, 0);
    writePlayerCredits();
    game.customOnPlayerCreditsChanged(this);
  }

  void writePlayerWeapons() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Weapons);
    writeUInt16(weaponType);
    writeUInt16(weaponPrimary);
    writeUInt16(weaponSecondary);
  }


  int getEquippedItemGroupItem(ItemGroup itemGroup) {
    switch (itemGroup){
      case ItemGroup.Primary_Weapon:
        return weaponPrimary;
      case ItemGroup.Secondary_Weapon:
        return weaponSecondary;
      case ItemGroup.Tertiary_Weapon:
        return weaponTertiary;
      case ItemGroup.Head_Type:
        return headType;
      case ItemGroup.Body_Type:
        return bodyType;
      case ItemGroup.Legs_Type:
        return legsType;
      case ItemGroup.Unknown:
        throw Exception('player.getEquippedItemGroupItem($itemGroup)');
    }
  }

  @override
  void onWeaponTypeChanged() {
    super.onWeaponTypeChanged();
    writePlayerWeapons();
  }

  int getNextItemFromItemGroup(ItemGroup itemGroup){

    final equippedItemType = getEquippedItemGroupItem(itemGroup);
    assert (equippedItemType != -1);
    final equippedItemIndex = getItemIndex(equippedItemType);
    assert (equippedItemType != -1);

    final itemEntries = item_level.entries.toList(growable: false);
    final itemEntriesLength = itemEntries.length;
    for (var i = equippedItemIndex + 1; i < itemEntriesLength; i++){
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      return entryItemType;
    }

    for (var i = 0; i < equippedItemIndex; i++){
      final entry = itemEntries[i];
      if (entry.value <= 0) continue;
      final entryItemType = entry.key;
      final entryItemGroup = ItemType.getItemGroup(entryItemType);
      if (entryItemGroup != itemGroup) continue;
      return entryItemType;
    }

    return ItemType.Empty;
  }

  void swapWeapons() {
    if (!canChangeEquipment) {
      return;
    }

    final a = weaponPrimary;
    final b = weaponSecondary;

    weaponPrimary = b;
    weaponSecondary = a;
    game.setCharacterStateChanging(this);
    writePlayerEquipment();
  }

  void writePlayerPower() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Power);
    writeByte(powerType);
    writeBool(powerCooldown <= 0);
  }

  void writeApiPlayersAll() {
    writeUInt8(ServerResponse.Api_Players);
    writeUInt8(ApiPlayers.All);
    writeUInt16(game.players.length);
    for (final player in game.players) {
      writeUInt24(player.id);
      writeString(player.name);
      writeUInt24(player.score);
    }
  }

  void writePlayerCredits() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Credits);
    writeUInt16(score);
  }

  void writeApiPlayersScore() {
    writeUInt8(ServerResponse.Api_Players);
    writeUInt8(ApiPlayers.All);
    writeUInt16(game.players.length);
    for (final player in game.players) {
      writeUInt24(player.id);
      writeString(player.name);
      writeUInt24(player.score);
    }
  }

  void writeApiPlayersPlayerScore(CombatPlayer player) {
    writeUInt8(ServerResponse.Api_Players);
    writeUInt8(ApiPlayers.Score);
    writeUInt24(player.id);
    writeUInt24(player.score);
  }
}