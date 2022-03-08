import 'package:bleed_client/classes/Character.dart';
import 'package:bleed_client/common/CharacterState.dart';
import 'package:bleed_client/common/ServerResponse.dart';
import 'package:bleed_client/common/compile_util.dart';
import 'package:bleed_client/parse.dart';
import 'package:bleed_client/state/game.dart';

final byteStreamParser = _ByteStreamParser();

class _ByteStreamParser {

  var _index = 0;
  late List<int> values;

  void parse(List<int> values){
    _index = 0;
    this.values = values;
    while (true) {
      switch(serverResponses[_nextByte()]){
        case ServerResponse.Zombies:
          final total = _nextInt();
          final zombies = game.zombies;
          game.totalZombies.value = total;
          for (var i = 0; i < total; i++){
            _readZombie(zombies[i]);
          }
          return;
        case ServerResponse.End:
          return;
      }
      _index++;
    }
  }

  void _readZombie(Character character){
     character.state = characterStates[_nextByte()];
     character.direction = _nextByte();
     character.x = _nextDouble();
     character.y = _nextDouble();
     character.frame = _nextByte();
     character.health = _nextByte() / 100.0;
     character.team = _nextByte();
  }

  int _nextByte(){
    final value = values[_index];
    _index++;
    return value;
  }

  int _nextInt(){
    final value = readInt(list: values, index: _index);
    _index += 3;
    return value;
  }

  double _nextDouble(){
    return _nextInt().toDouble();
  }
}