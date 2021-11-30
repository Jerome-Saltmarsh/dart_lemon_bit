import 'package:bleed_client/common/ClientRequest.dart';
import 'package:bleed_client/input.dart';
import 'package:bleed_client/network/functions/send.dart';
import 'package:bleed_client/network/functions/sinkMessage.dart';
import 'package:bleed_client/render/state/paths.dart';
import 'package:bleed_client/state/game.dart';

import 'common/CharacterState.dart';
final StringBuffer _buffer = StringBuffer();
final gameUpdateIndex = ClientRequest.Update.index;
const String _space = " ";

String get session => game.player.uuid;

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

void sendRequestEquip(int index) {
  send('${ClientRequest.Equip.index} $session $index');
}

void skipHour(){
  send(ClientRequest.SkipHour.index.toString());
}

void reverseHour(){
  send(ClientRequest.ReverseHour.index.toString());
}

String get aim => characterController.requestAim.toStringAsFixed(2);

void requestThrowGrenade(double strength) {
  send('${ClientRequest.Grenade.index} $session ${strength.toStringAsFixed(1)} $aim');
}

void sendRequestAcquireAbility() {
  send('${ClientRequest.AcquireAbility.index} $session');
}

void sendRequestUpdatePlayer() {
  _buffer.clear();
  _write(gameUpdateIndex);
  _write(game.player.uuid);
  _write(characterController.characterState.index);
  _write(characterController.direction.index);
  if (characterController.characterState == CharacterState.Firing) {
    _write(characterController.requestAim.toStringAsFixed(2));
  } else {
    _write(characterController.requestAim.toStringAsFixed(1));
  }
  send(_buffer.toString());
}

void sendRequestSetCompilePaths(bool value) {
  paths.clear();
  send('${ClientRequest.SetCompilePaths.index} $session ${value ? 1 : 0}');
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
