
import '../classes/player.dart';
import '../classes/scene.dart';
import '../common/library.dart';
import '../scene/generate_empty_scene.dart';
import 'dark_age_environment.dart';
import 'game_dark_age.dart';

class GameDarkAgeEditor extends GameDarkAge {

  @override
  int get gameType => GameType.Editor;

  GameDarkAgeEditor({Scene? scene}) : super(scene ?? generateEmptyScene(), DarkAgeEnvironment(DarkAgeTime()));

  @override
  void customUpdate(){
    environment.update();
  }

  @override
  void customOnPlayerDisconnected(Player player) {
      removeFromEngine();
  }

  @override
  void customOnPlayerRevived(Player player) {
     if (isSafeToRevive(25, 25)){
       player.indexColumn = 25;
       player.indexRow = 25;
       player.indexZ = 8;
       player.state = CharacterState.Idle;
       return;
     }

     for (var row = 0; row < scene.gridRows; row++) {
        for (var column = 0; column < scene.gridColumns; column++){
          if (isSafeToRevive(row, column)){
            player.indexColumn = column;
            player.indexRow = row;
            player.indexZ = 8;
            return;
          }
        }
     }
  }

  bool isSafeToRevive(int row, int column) {
     for (var z = scene.gridHeight - 1; z >= 0; z--){
       final type = scene.getGridType(z, row, column);
        if (type == NodeType.Water) return false;
        if (type == NodeType.Water_Flowing) return false;
     }
     return true;
  }
}