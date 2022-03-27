
import 'dart:typed_data';
import 'dart:convert' show utf8;
import 'package:lemon_math/angle.dart';

import 'classes/Character.dart';
import 'classes/Game.dart';
import 'classes/GameEvent.dart';
import 'classes/GameObject.dart';
import 'classes/Player.dart';
import 'classes/Projectile.dart';
import 'common/ServerResponse.dart';
import 'common/compile_util.dart';
import 'common/constants.dart';

final byteCompiler = _ByteCompiler();

final _serverResponsePlayerIndex = ServerResponse.Player.index;
final _serverResponseZombiesIndex = ServerResponse.Zombies.index;
final _serverResponsePlayersIndex = ServerResponse.Players.index;
final _serverResponseEndIndex = ServerResponse.End.index;
final _serverResponseGameEventsIndex = ServerResponse.Game_Events.index;
final _serverResponseProjectilesIndex = ServerResponse.Projectiles.index;
final _serverResponseGameTimeIndex = ServerResponse.Game_Time.index;

class _ByteCompiler {
  var _index = 0;
  final _buffer = Uint8List(100000); // 100kb
  final List<Uint8List> _buffers = [];


  _ByteCompiler(){
    _buffers.add(Uint8List(75));
    _buffers.add(Uint8List(85));
    _buffers.add(Uint8List(100));
    _buffers.add(Uint8List(125));
    _buffers.add(Uint8List(150));
    _buffers.add(Uint8List(175));
    _buffers.add(Uint8List(200));
    _buffers.add(Uint8List(250));
    _buffers.add(Uint8List(300));
    _buffers.add(Uint8List(350));
  }

  List<int> writeToSendBuffer() {
    writeByte(_serverResponseEndIndex);
    final sendBuffer = _getSendBuffer();
    for (var i = 0; i < _index; i++) {
      sendBuffer[i] = _buffer[i];
    }
    _index = 0;
    return sendBuffer;
  }

  void writePlayerGame(Player player){
    final slots = player.slots;
    final orbs = player.orbs;
    final game = player.game;
    writePlayers(player);
    writeByte(_serverResponsePlayerIndex);
    writeBigInt(player.x);
    writeBigInt(player.y);
    writeBigInt(player.health);
    writeBigInt(player.maxHealth);
    writeBigInt(player.magic);
    writeBigInt(player.maxMagic);
    writeSlot(slots.weapon);
    writeByte(slots.armour.type.index);
    writeByte(slots.helm.type.index);
    writeSlot(slots.slot1);
    writeSlot(slots.slot2);
    writeSlot(slots.slot3);
    writeSlot(slots.slot4);
    writeSlot(slots.slot5);
    writeSlot(slots.slot6);
    writeBigInt(orbs.topaz); // 2
    writeBigInt(orbs.emerald); // 2
    writeBigInt(orbs.ruby); // 2
    writeBool(player.alive); // 1
    writeBool(player.storeVisible); // 1
    writeAttackTarget(player);
    writeProjectiles(game.projectiles);
    writeNpcs(player);
    writeGameEvents(game.gameEvents);
    writeGameTime(game);
    writePlayerZombies(player);
    writeItems(player);
    writePlayerEvents(player);

    if (game.debugMode)
      writePaths(game);
  }

  void writePlayerEvents(Player player){
    final events = player.events;
    if (events.isEmpty) return;
    writeByte(ServerResponse.Player_Events.index);
    writeByte(events.length);
    for (var i = 0; i < events.length; i++) {
      writeByte(events[i].index);
    }
    events.clear();
  }

  void writeBool(bool value){
    writeByte(value ? 1 : 0);
  }

  void writePaths(Game game) {
    writeByte(ServerResponse.Paths.index);
    final zombies = game.zombies;
    for (final zombie in zombies) {
      if (!zombie.active) continue;
      final ai = zombie.ai;
      if (ai == null) continue;
      final pathIndex = ai.pathIndex;
      if (pathIndex < 0) continue;
      writeBigInt(pathIndex + 1);
      for (var i = pathIndex; i >= 0; i--) {
        writeBigInt(ai.pathX[i]);
        writeBigInt(ai.pathY[i]);
      }
    }
    writeBigInt(250);
  }

  void writeItems(Player player){
    writeByte(ServerResponse.Items.index);
    final items = player.game.items;
    for(final item in items){
      if (item.inactive) continue;
      if (item.left < player.screenLeft) continue;
      if (item.right > player.screenRight) continue;
      if (item.top < player.screenTop) continue;
      if (item.bottom > player.screenBottom) break;
      writeByte(item.type.index);
      writeBigInt(item.x);
      writeBigInt(item.y);
    }
    writeByte(END);
  }

  void writePlayerZombies(Player player) {
    writeByte(_serverResponseZombiesIndex);
    final zombies = player.game.zombies;
    final length = zombies.length;
    final top = player.screenTop;
    final bottom = player.screenBottom;
    final left = player.screenLeft;
    final right = player.screenRight;
    final lengthMinusOne = length - 1;

    if (length == 0) {
      writeByte(END);
      return;
    }
    var start = 0;
    for (start = 0; start < lengthMinusOne; start++){
      final zombieY = zombies[start].y;
      if (zombieY > top) {
        if (zombieY > bottom){
          writeByte(END);
          return;
        }
        break;
      }
    }

    var end = start;
    for (end = start; end < lengthMinusOne; end++) {
      if (zombies[end].y > bottom) break;
    }

    for(var i = start; i <= end; i++){
      final zombie = zombies[i];
      if (zombie.dead) continue;
      if (zombie.x < left) continue;
      if (zombie.x > right) continue;
      writeCharacter(player, zombie);
    }
    writeByte(END);
  }

  void writeGameEvents(List<GameEvent> gameEvents){
    writeByte(_serverResponseGameEventsIndex);
    var total = 0;
    for (final gameEvent in gameEvents) {
      if (gameEvent.frameDuration <= 0) continue;
      total++;
    }
    writeBigInt(total);
    for (final gameEvent in gameEvents) {
      if (gameEvent.frameDuration <= 0) continue;
      writeBigInt(gameEvent.id);
      writeByte(gameEvent.type.index);
      writeBigInt(gameEvent.x);
      writeBigInt(gameEvent.y);
      writeBigInt(gameEvent.angle);
    }
  }

  void writeProjectiles(List<Projectile> projectiles){
    writeByte(_serverResponseProjectilesIndex);
    writeTotalActive(projectiles);
    projectiles.forEach(writeProjectile);
  }

  void writeGameTime(Game game){
    writeByte(_serverResponseGameTimeIndex);
    final totalSeconds = game.getTime();
    final totalMinutes = totalSeconds ~/ 60;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    writeByte(hours);
    writeByte(minutes);
  }

  void writeTotalActive(List<GameObject> values){
    var total = 0;
    for (final gameObject in values) {
      if (!gameObject.active) continue;
      total++;
    }
    writeBigInt(total);
  }

  void writeProjectile(Projectile projectile){
    if (!projectile.active) return;
    final degrees = angle(projectile.xv, projectile.yv) * radiansToDegrees;
    writeBigInt(projectile.x);
    writeBigInt(projectile.y);
    writeByte(projectile.type.index);
    writeBigInt(degrees);
  }

  void writePlayers(Player player){
    writeByte(_serverResponsePlayersIndex);
    final players = player.game.players;
    for (final otherPlayer in players) {
      if (otherPlayer.dead) continue;
      // players on same team emit light offscreen
      bool onSameTeam = sameTeam(otherPlayer, player);

      if (!onSameTeam) {
        if (otherPlayer.top < player.screenTop) continue;
        if (otherPlayer.bottom > player.screenBottom) continue;
        if (otherPlayer.left < player.screenLeft) continue;
        if (otherPlayer.right > player.screenRight) continue;
      }
      writePlayer(otherPlayer);
      if (onSameTeam){
        writeString(otherPlayer.text);
      } else {
        writeBigInt(0);
      }
    }
    writeByte(END);
  }

  void writeAttackTarget(Player player){
    final aimTarget = player.aimTarget;
    if (aimTarget == null){
      writeByte(ServerResponse.Player_Attack_Target_None.index);
      return;
    }
    writeByte(ServerResponse.Player_Attack_Target.index);
    writeBigInt(aimTarget.x);
    writeBigInt(aimTarget.y);
  }

  void writePlayer(Player player) {
    final slots = player.slots;
    writeCharacter(player, player);
    writePercentage(player.magicPercentage);
    writeByte(slots.weapon.type.index);
    writeByte(slots.armour.type.index);
    writeByte(slots.helm.type.index);
    writeString(player.name);
  }
  
  void writeString(String value){
    writeBigInt(value.length);
    if (value.length == 0) return;
    final encoded = utf8.encode(value);
    for(final character in encoded){
      writeByte(character);
    }
  }

  void writeNpcs(Player player){
    final npcs = player.game.npcs;
    writeByte(ServerResponse.Npcs.index);
    writeTotalActive(npcs);
    for(final npc in npcs) {
      writeNpc(player, npc);
    }
  }

  void writeNpc(Player player, Character npc) {
    if (!npc.active) return;
    writeCharacter(player, npc);
    writeByte(npc.slots.weapon.type.index);
  }

  void writeCharacter(Player player, Character character) {
    final allie = sameTeam(player, character) ? 100 : 0;
    final directionInt = character.direction * 10;
    final stateInt = character.state.index;
    final value = allie + directionInt + stateInt;
    writeByte(value); // 1
    writeBigInt(character.x); // 2
    writeBigInt(character.y); // 2
    final healthPercentage = ((character.health / character.maxHealth) * 24).toInt() * 10;
    writeByte(healthPercentage + character.animationFrame);
  }

  List<int> _getSendBuffer() {
    final buffersLength = _buffers.length;
     for (var i = 0; i < buffersLength; i++) {
       final buff = _buffers[i];
       if (_index < buff.length){
         return buff;
       }
     }
     final newBufferLength = _index ~/ 100 * 100 + 100;
     final buffer = Uint8List(newBufferLength);
     _buffers.add(buffer);
     return buffer;
  }

  void writePercentage(double value){
    writeByte((value * 100).toInt());
  }

  void writeBigInt(num value){
    writeNumberToByteArray(number: value, list: _buffer, index: _index);
    _index += 2;
  }

  void writeByte(int value){
    assert(value <= 256);
    assert(value >= 0);
    _buffer[_index] = value;
    _index++;
  }

  void writeSlot(Slot slot){
    writeByte(slot.type.index);
    writeBigInt(slot.amount);
  }
}