
import '../classes/library.dart';
import '../io/load_scene.dart';
import '../isometric/generate_empty_grid.dart';

final darkAgeScenes = DarkAgeScenes();

class DarkAgeScenes {

  late Scene village;
  late Scene castle;
  late Scene forest;
  late Scene farm;
  late Scene darkFortress;
  late Scene darkFortressDungeon;
  late Scene tavernCellar;
  late Scene farmA;
  late Scene farmB;
  late Scene mountainShrine;
  late Scene lake;
  late Scene town;
  late Scene plains1;
  late Scene forestB;
  late Scene mountains1;
  late Scene empty;

  Future load() async {
      print('Loading dark age scenes');
      farmA = await loadScene('farm-a');
      farmB = await loadScene('farm-b');
      village = await loadScene('village');
      castle = await loadScene('castle');
      forest = await loadScene('forest');
      farm = await loadScene('farm');
      darkFortress = await loadScene('dark-fortress');
      darkFortressDungeon = await loadScene('dark-fortress-dungeon');
      tavernCellar = await loadScene('tavern-cellar');
      mountainShrine = await loadScene('mountain-shrine');
      lake = await loadScene('lake');
      town = await loadScene('town');
      plains1 = await loadScene('plains-1');
      forestB = await loadScene('forest-b');
      mountains1 = await loadScene('mountains-1');
      empty = Scene(
          name: 'empty',
          characters: [],
          enemySpawns: [],
          grid: generateEmptyGrid(
              zHeight: 1,
              rows: 10,
              columns: 10
          ),
      );
      print("Loading dark age scenes finished");

  }
}