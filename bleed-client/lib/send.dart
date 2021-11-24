import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/PurchaseType.dart';
import 'package:bleed_client/network/functions/send.dart';
import 'package:bleed_client/network/functions/sinkMessage.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/state/game.dart';

import 'common/CharacterState.dart';
import 'common/Weapons.dart';
import 'state.dart';

final StringBuffer _buffer = StringBuffer();
final gameUpdateIndex = ClientRequest.Update.index;
const String _space = " ";

void speak(String message){
  if (message.isEmpty) return;
  send('${ClientRequest.Speak.index} $session $message');
}

void sendRequestInteract(){
  send('${ClientRequest.Interact.index} $session');
}

void sendRequestPing(){
  sinkMessage(ClientRequest.Ping.index.toString());
}

void sendRequestRevive() {
  send('${ClientRequest.Revive.index} $session');
}

void sendRequestTeleport(double x, double y){
  send('${ClientRequest.Teleport.index} $session ${x.toInt()} ${y.toInt()} ');
}

void sendRequestCastFireball(){
  send('${ClientRequest.CasteFireball.index} $session $aim');
}

void sendRequestEquip(Weapon weapon) {
  send('${ClientRequest.Equip.index} $session ${weapon.index}');
}

void skipHour(){
  send(ClientRequest.SkipHour.index.toString());
}

void reverseHour(){
  send(ClientRequest.ReverseHour.index.toString());
}

void sendRequestEquipHandgun() {
  sendRequestEquip(Weapon.HandGun);
}

void sendRequestEquipShotgun() {
  sendRequestEquip(Weapon.Shotgun);
}

void sendRequestEquipSniperRifle() {
  sendRequestEquip(Weapon.SniperRifle);
}

void sendRequestUpdateLobby() {
  // send(
  //     '${ClientRequest.Lobby_Update.index.toString()} ${state.lobby.uuid} ${state.lobby.playerUuid}');
}

void sendRequestLobbyExit() {
  if (state.lobby == null) {
    print("sendRequestLobbyExit() state.lobby is null");
    return;
  }
  // send(
  //     '${ClientRequest.Lobby_Exit.index.toString()} ${state.lobby.uuid} ${state.lobby.playerUuid}');
}

void sendRequestEquipAssaultRifle() {
  sendRequestEquip(Weapon.AssaultRifle);
}

String get aim => requestAim.toStringAsFixed(2);

void requestThrowGrenade(double strength) {
  send('${ClientRequest.Grenade.index} $session ${strength.toStringAsFixed(1)} $aim');
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(gameUpdateIndex);
  _write(game.gameId);
  _write(game.playerId);
  _write(game.playerUUID);
  _write(requestCharacterState.index);
  _write(requestDirection.index);
  if (requestCharacterState == CharacterState.Firing) {
    _write(requestAim.toStringAsFixed(2));
  } else {
    _write(requestAim.toInt());
  }
  send(_buffer.toString());
}


void sendRequestPurchase(PurchaseType purchaseType) {
  send('${ClientRequest.Purchase.index} $session ${purchaseType.index}');
}

void sendRequestSetCompilePaths(bool value) {
  paths.clear();
  send('${ClientRequest.SetCompilePaths.index} $session ${value ? 1 : 0}');
}

void purchaseAmmoHandgun() {
  sendRequestPurchase(PurchaseType.Ammo_Handgun);
}

void purchaseAmmoShotgun() {
  sendRequestPurchase(PurchaseType.Ammo_Shotgun);
}

void purchaseWeaponHandgun() {
  sendRequestPurchase(PurchaseType.Weapon_Handgun);
}

void purchaseWeaponShotgun() {
  sendRequestPurchase(PurchaseType.Weapon_Shotgun);
}

void purchaseWeaponSniperRifle() {
  sendRequestPurchase(PurchaseType.Weapon_SniperRifle);
}

void purchaseWeaponAssaultRifle() {
  sendRequestPurchase(PurchaseType.Weapon_AssaultRifle);
}

void sendRequestPurchaseWeapon(Weapon weapon) {
  switch (weapon) {
    case Weapon.HandGun:
      purchaseWeaponHandgun();
      break;
    case Weapon.Shotgun:
      purchaseWeaponShotgun();
      break;
    case Weapon.SniperRifle:
      purchaseWeaponSniperRifle();
      break;
    case Weapon.AssaultRifle:
      purchaseWeaponAssaultRifle();
      break;
    default:
      throw Exception("Could not request purchase $weapon");
  }
}

void sendClientRequest(ClientRequest request) {
  send(request.index.toString());
}

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

void request(ClientRequest request, String value) {
  send('${request.index} $value');
}
