import 'package:bleed_client/classes/RenderState.dart';
import 'package:bleed_client/common.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/GameType.dart';
import 'package:bleed_client/common/PurchaseType.dart';
import 'package:bleed_client/functions/clearState.dart';
import 'package:bleed_client/network/functions/send.dart';
import 'package:bleed_client/network/functions/sinkMessage.dart';
import 'package:bleed_client/properties.dart';

import 'common/Weapons.dart';
import 'state.dart';

final StringBuffer _buffer = StringBuffer();
final gameUpdateIndex = ClientRequest.Game_Update.index;
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
  send('${ClientRequest.Player_Revive.index} $session');
}

void sendRequestEquip(Weapon weapon) {
  send('${ClientRequest.Player_Equip.index} $session ${weapon.index}');
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
  send(
      '${ClientRequest.Lobby_Update.index.toString()} ${state.lobby.uuid} ${state.lobby.playerUuid}');
}

void sendRequestJoinGame(String gameUuid) {
  send('${ClientRequest.Game_Join.index.toString()} $gameUuid');
}

void sendRequestLobbyExit() {
  if (state.lobby == null) {
    print("sendRequestLobbyExit() state.lobby is null");
    return;
  }
  send(
      '${ClientRequest.Lobby_Exit.index.toString()} ${state.lobby.uuid} ${state.lobby.playerUuid}');
}

void sendRequestEquipAssaultRifle() {
  sendRequestEquip(Weapon.AssaultRifle);
}

void requestThrowGrenade(double strength) {
  send(
      '${ClientRequest.Player_Throw_Grenade.index} $session ${strength.toStringAsFixed(1)} ${requestAim.toStringAsFixed(2)}');
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(gameUpdateIndex);
  _write(compiledGame.gameId);
  _write(compiledGame.playerId);
  _write(compiledGame.playerUUID);
  _write(requestCharacterState);
  _write(requestDirection);
  if (requestCharacterState == characterStateFiring) {
    _write(requestAim.toStringAsFixed(2));
  } else {
    _write(requestAim.toInt());
  }
  _write(serverFrame);
  send(_buffer.toString());
}

void sendRequestUpdateScore() {
  if (state.compiledGame.gameId < 0) return;
  if (editMode) return;
  if (compiledGame.gameType == GameType.Open_World) return;
  send('${ClientRequest.Score.index} ${state.compiledGame.gameId}');
}

void sendRequestJoinGameFortress() {
  send(ClientRequest.Lobby_Join_Fortress.index.toString());
}

void sendRequestJoinLobby(String lobbyUuid) {
  send('${ClientRequest.Lobby_Join.index} $lobbyUuid');
}

void sendRequestLobbyList() {
  send(ClientRequest.Lobby_List.index.toString());
}

void sendClientRequestLobbyCreate(
    {int maxPlayers, GameType type, String name, bool private}) {
  send(
      '${ClientRequest.Lobby_Create.index} $maxPlayers ${type.index} $name ${private ? "1" : "0"}');
}

void requestJoinRandomGame() {
  sendClientRequest(ClientRequest.Game_Join_Casual);
}

void sendRequestJoinLobbyDeathMatch({int squadSize = 1}) {
  clearState();
  send('${ClientRequest.Lobby_Join_DeathMatch.index} $squadSize');
}

void sendRequestJoinLobbyFortress() {
  // TODO does not belong
  clearState();
  sendClientRequest(ClientRequest.Lobby_Join_Fortress);
}

void sendRequestPurchase(PurchaseType purchaseType) {
  send('${ClientRequest.Purchase.index} $session ${purchaseType.index}');
}

void sendRequestSetCompilePaths(bool value) {
  render.paths.clear();
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

void sendRequestSpawnNpc() {
  send('${ClientRequest.Spawn_Npc.index} $session');
}

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

void request(ClientRequest request, String value) {
  send('${request.index} $value');
}
