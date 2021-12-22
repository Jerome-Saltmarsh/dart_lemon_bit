import 'package:bleed_client/common/CharacterAction.dart';
import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/common/WeaponType.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/state/game.dart';
import 'package:lemon_engine/properties/mouse_world.dart';

import 'network.dart';

final StringBuffer _buffer = StringBuffer();
final gameUpdateIndex = ClientRequest.Update.index;
const String _space = " ";

final _SendRequestToServer sendRequest = _SendRequestToServer();

String get session => game.session;

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
  // send('${ClientRequest.CasteFireball.index} $session $aim');
}

void sendRequestEquip(int index) {
  send('${ClientRequest.Equip.index} $session $index');
}

void sendRequestDeselectAbility() {
  send('${ClientRequest.DeselectAbility.index} $session');
}

void sendRequestSelectAbility(int index) {
  if (index < 1 || index > 4){
    throw Exception("sendRequestSelectAbility(index: $index) - index must be between 1 and 4 inclusive");
  }
  send('${ClientRequest.SelectAbility.index} $session $index');
}

void skipHour(){
  send(ClientRequest.SkipHour.index.toString());
}

void reverseHour(){
  send(ClientRequest.ReverseHour.index.toString());
}


void requestThrowGrenade(double strength) {
  // send('${ClientRequest.Grenade.index} $session ${strength.toStringAsFixed(1)} $aim');
}

void sendRequestAcquireShotgun(){
  sendRequestAcquireAbility(WeaponType.Shotgun);
}

void sendRequestAcquireHandgun(){
  sendRequestAcquireAbility(WeaponType.HandGun);
}

void sendRequestAcquireFirebolt(){
  sendRequestAcquireAbility(WeaponType.Firebolt);
}

void sendRequestJoinGame() {
  send('${ClientRequest.Join.index}');
}

void sendRequestJoinGameMoba() {
  send('${ClientRequest.Join_Moba.index}');
}

void sendRequestJoinGameOpenWorld() {
  print("sendRequestJoinGameOpenWorld()");
  send('${ClientRequest.Join.index}');
}

void sendRequestJoinGameDefense() {
  send('${ClientRequest.Join_Defense.index}');
}

void sendRequestAcquireAbility(WeaponType type) {
  send('${ClientRequest.AcquireAbility.index} $session ${type.index}');
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(gameUpdateIndex);
  _write(session);
  _write(characterController.action.value.index);
  characterController.action.value = CharacterAction.Idle;
  _write(characterController.direction.index);
  _write(mouseWorldX.toInt());
  _write(mouseWorldY.toInt());
  send(_buffer.toString());

}

void sendRequestSetCompilePaths(bool value) {
  paths.clear();
  send('${ClientRequest.SetCompilePaths.index} $session ${value ? 1 : 0}');
}

void sendClientRequest(ClientRequest request, {dynamic message = ""}) {
  send('${request.index} $session $message');
}

void _write(dynamic value) {
  _buffer.write(value);
  _buffer.write(_space);
}

void request(ClientRequest request, String value) {
  send('${request.index} $value');
}

class _SendRequestToServer {
  upgradeAbility(int index){
    sendClientRequest(ClientRequest.Upgrade_Ability, message: index);
  }
}
