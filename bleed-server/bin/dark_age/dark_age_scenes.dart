
import '../classes/library.dart';
import '../io/load_scene.dart';

final darkAgeScenes = DarkAgeScenes();

class DarkAgeScenes {

  late Scene village;
  late Scene castle;
  late Scene forest;
  late Scene farm;

  Future load() async{
      print('Loading dark age scenes');
      village = await loadScene('village');
      castle = await loadScene('castle');
      forest = await loadScene('forest');
      farm = await loadScene('farm');
      print("Loading dark age scenes finished");
  }
}