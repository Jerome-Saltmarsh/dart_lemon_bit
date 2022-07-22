
import '../classes/library.dart';
import '../io/load_scene.dart';

final darkAgeScenes = DarkAgeScenes();

class DarkAgeScenes {

  late Scene village;
  late Scene castle;
  late Scene forest;
  late Scene farm;
  late Scene darkFortress;
  late Scene darkFortressDungeon;
  late Scene tavernCellar;

  Future load() async{
      print('Loading dark age scenes');
      village = await loadScene('village');
      castle = await loadScene('castle');
      forest = await loadScene('forest');
      farm = await loadScene('farm');
      darkFortress = await loadScene('dark-fortress');
      darkFortressDungeon = await loadScene('dark-fortress-dungeon');
      tavernCellar = await loadScene('tavern-cellar');
      print("Loading dark age scenes finished");
  }
}