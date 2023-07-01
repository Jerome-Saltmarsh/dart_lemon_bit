
import 'dart:math';

import 'package:gamestream_server/common.dart';
import 'package:gamestream_server/gamestream.dart';

import 'package:gamestream_server/isometric/src.dart';
import 'package:lemon_math/src.dart';

import 'combat_game.dart';


class CombatPlayer extends IsometricPlayer {

  var energyGainRate = 16;
  var powerCooldown = 0;
  var weaponPrimary = WeaponType.Unarmed;
  var weaponSecondary = WeaponType.Unarmed;
  var weaponTertiary = WeaponType.Unarmed;
  var maxEnergy = 10;
  var aimTargetWeaponSide = IsometricSide.Left;
  var nextEnergyGain = 0;

  var buffInvincible      = false;
  var buffDoubleDamage    = false;
  var buffInvisible       = false;

  var _energy = 10;
  var _powerType = CombatPowerType.None;
  var _credits = 0;
  var _respawnTimer = 0;

  final CombatGame game;

  CombatPlayer(this.game) : super(game: game) {
    maxEnergy = energy;
    _energy = maxEnergy;
  }

  bool get weaponPrimaryEquipped => weaponType == weaponPrimary;
  bool get weaponSecondaryEquipped => weaponType == weaponSecondary;

  int get score => _credits;
  int get powerType => _powerType;
  int get energy => _energy;
  int get respawnTimer => _respawnTimer;

  double get magicPercentage {
    if (_energy == 0) return 0;
    if (maxEnergy == 0) return 0;
    return _energy / maxEnergy;
  }


  set respawnTimer(int value){
    if (_respawnTimer == value) return;
    _respawnTimer = value;
    writeApiPlayerRespawnTimer();
  }

  set powerType(int value) {
    if (_powerType == value) return;
    assert (CombatPowerType.values.contains(value));
    if (!CombatPowerType.values.contains(value)) return;
    _powerType = value;
    writePlayerPower();
  }

  set score(int value) {
    if (_credits == value) return;
    _credits = max(value, 0);
    writePlayerCredits();
    game.customOnPlayerCreditsChanged(this);
  }

  set energy(int value) {
    final clampedValue = clamp(value, 0, maxEnergy);
    if (_energy == clampedValue) return;
    _energy = clampedValue;
    writePlayerEnergy();
  }

  void writePlayerWeapons() {
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Weapons);
    writeUInt16(weaponType);
    writeUInt16(weaponPrimary);
    writeUInt16(weaponSecondary);
  }

  @override
  void onWeaponTypeChanged() {
    super.onWeaponTypeChanged();
    writePlayerWeapons();
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

  void writePlayerEnergy() {
    writeUInt8(ServerResponse.Api_Player);
    writeUInt8(ApiPlayer.Energy);
    if (maxEnergy == 0) return writeByte(0);
    writePercentage(energy / maxEnergy);
  }

  int getPlayerPowerTypeCooldownTotal() {
    return Gamestream.Frames_Per_Second * 10;
  }

  void writeApiPlayerRespawnTimer(){
    writeByte(ServerResponse.Api_Player);
    writeByte(ApiPlayer.Respawn_Timer);
    writeUInt16(_respawnTimer);
  }
}