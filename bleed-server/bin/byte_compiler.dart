
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

const _60 = 60;
const _100 = 100;
const _256 = 256;

final byteCompiler = _ByteCompiler();

class _ByteCompiler {
  var _index = 0;
  final _buffer = Uint8List(100000); // 100kb
  final List<Uint8List> _buffers = [];

  List<int> writeToSendBuffer() {
    writeByte(ServerResponse.End.index);
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
    writePlayers(player);
    writeByte(ServerResponse.Player.index);
    writeBigInt(player.x);
    writeBigInt(player.y);
    writeBigInt(player.health);
    writeBigInt(player.maxHealth);
    writeBigInt(player.magic);
    writeBigInt(player.maxMagic);
    writeByte(player.weapon.index);
    writeByte(player.slots.armour.index);
    writeByte(player.slots.helm.index);
    writeByte(slots.slot1.index);
    writeByte(slots.slot2.index);
    writeByte(slots.slot3.index);
    writeByte(slots.slot4.index);
    writeByte(slots.slot5.index);
    writeByte(slots.slot6.index);
    writeBigInt(orbs.topaz);
    writeBigInt(orbs.emerald);
    writeBigInt(orbs.ruby);
    writeBool(player.alive);
    writeAttackTarget(player);
    writeGame(player.game);
    writePlayerZombies(player);
  }

  void writeBool(bool value){
    writeByte(value ? 1 : 0);
  }

  void writeGame(Game game){
    writeProjectiles(game.projectiles);
    writeNpcs(game.npcs);
    writeGameEvents(game.gameEvents);
    writeGameTime(game);

    if (game.debugMode)
      writePaths(game);
  }

  void writePaths(Game game) {
    writeByte(ServerResponse.Paths.index);
    for (final zombie in game.zombies) {
      if (!zombie.active) continue;
      final ai = zombie.ai;
      if (ai == null) continue;
      if (ai.pathIndex < 0) continue;
      writeBigInt(ai.pathIndex + 1);
      for (var i = ai.pathIndex; i >= 0; i--) {
        writeBigInt(ai.pathX[i]);
        writeBigInt(ai.pathY[i]);
      }
    }
    writeBigInt(250);
  }

  void writePlayerZombies(Player player) {
    writeByte(ServerResponse.Zombies.index);
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
      if (zombies[start].y > top) {
        if (zombies[start].y > bottom){
          writeByte(END);
          return;
        }
        break;
      }
    }

    var end = start;
    for (end = start; end < lengthMinusOne; end++){
      if (zombies[end].y > bottom) break;
    }

    for(var i = start; i <= end; i++){
      final zombie = zombies[i];
      if (zombie.x < left) continue;
      if (zombie.x > right) continue;
      writeCharacter(zombie);
    }
    writeByte(END); // ZOMBIES FINISHED;  see bytestream_parser._parseZombies();
  }

  void writeZombies(List<Character> zombies){
    writeByte(ServerResponse.Zombies.index);
    writeTotalActive(zombies);
    for (final zombie in zombies) {
      if (!zombie.active) continue;
      writeCharacter(zombie);
    }
  }

  void writeGameEvents(List<GameEvent> gameEvents){
    writeByte(ServerResponse.Game_Events.index);
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
    writeByte(ServerResponse.Projectiles.index);
    writeTotalActive(projectiles);
    projectiles.forEach(writeProjectile);
  }

  void writeGameTime(Game game){
    writeByte(ServerResponse.Game_Time.index);
    final totalSeconds = game.getTime();
    final totalMinutes = totalSeconds ~/ _60;
    final hours = totalMinutes ~/ _60;
    final minutes = totalMinutes % _60;
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
    writeByte(ServerResponse.Players.index);
    final players = player.game.players;
    for(final otherPlayer in players) {
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
    writeCharacter(player);
    writePercentage(player.magic / player.maxMagic);
    writeByte(player.weapon.index);
    writeByte(player.slots.armour.index);
    writeByte(player.slots.helm.index);
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

  void writeNpcs(List<Character> npcs){
    writeByte(ServerResponse.Npcs.index);
    writeTotalActive(npcs);
    npcs.forEach(writeNpc);
  }

  void writeNpc(Character npc) {
    if (!npc.active) return;
    writeCharacter(npc);
    writeByte(npc.weapon.index);
  }

  void writeCharacter(Character character){
    writeByte(character.state.index);
    writeByte(character.direction);
    writeBigInt(character.x);
    writeBigInt(character.y);
    writeByte(character.animationFrame);
    writePercentage(character.health / character.maxHealth);
    writeByte(character.team);
  }

  List<int> _getSendBuffer(){
     for (var i = 0; i < _buffers.length; i++) {
       final buff = _buffers[i];
       if (_index < buff.length){
         return buff;
       }
     }
     final newBufferLength = _index ~/ _100 * _100 + _100;
     final buffer = Uint8List(newBufferLength);
     _buffers.add(buffer);
     return buffer;
  }

  void writePercentage(double value){
    writeByte((value * _100).toInt());
  }

  void writeBigInt(num value){
    writeNumberToByteArray(number: value, list: _buffer, index: _index);
    if (value >= -_256 && value <= _256){
      _index += 2;
    } else {
      _index += 3;
    }
  }

  void writeByte(int value){
    assert(value <= _256);
    assert(value >= 0);
    _buffer[_index] = value;
    _index++;
  }
}