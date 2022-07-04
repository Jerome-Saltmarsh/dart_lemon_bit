
import '../classes/library.dart';
import '../io/load_scene.dart';

final darkAgeScenes = DarkAgeScenes();

class DarkAgeScenes {

  late Scene village;
  late Scene castle;

  Future load() async{
      print('Loading dark age scenes');
      village = await loadScene('village');
      castle = await loadScene('castle');
      print("Loading dark age scenes finished");
  }
}