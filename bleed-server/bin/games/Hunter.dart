
import '../classes/Game.dart';
import '../common/GameStatus.dart';
import '../instances/scenes.dart';

class Hunter extends Game {
  Hunter() : super(scenes.wildernessWest01){
    status = GameStatus.In_Progress;
  }

  @override
  void update() {
  }
}