
import '../classes/library.dart';
import '../io/load_scene.dart';
import '../isometric/generate_empty_grid.dart';

final darkAgeScenes = DarkAgeScenes();

class DarkAgeScenes {
  late Scene village;
  late Scene castle;
  late Scene forest;
  late Scene forest_2;
  late Scene forest_3;
  late Scene forest_4;
  late Scene farm;
  late Scene darkFortress;
  late Scene darkFortressDungeon;
  late Scene tavernCellar;
  late Scene farmA;
  late Scene farmB;
  late Scene mountainShrine;
  late Scene lake;
  late Scene town;
  late Scene plains_1;
  late Scene plains_2;
  late Scene plains_3;
  late Scene plains_4;
  late Scene mountains_1;
  late Scene mountains_2;
  late Scene mountains_3;
  late Scene mountains_4;
  late Scene empty;
  late Scene outpost_1;
  late Scene shrine_1;

  Future load() async {
      print('Loading dark age scenes');
      farm = await loadScene('farm');
      farmA = await loadScene('farm-a');
      farmB = await loadScene('farm-b');
      village = await loadScene('village');
      castle = await loadScene('castle');
      forest = await loadScene('forest');
      forest_2 = await loadScene('forest-b');
      forest_3 = await loadScene('forest-3');
      forest_4 = await loadScene('forest-4');
      darkFortress = await loadScene('dark-fortress');
      darkFortressDungeon = await loadScene('dark-fortress-dungeon');
      tavernCellar = await loadScene('tavern-cellar');
      mountainShrine = await loadScene('mountain-shrine');
      lake = await loadScene('lake');
      town = await loadScene('town');
      plains_1 = await loadScene('plains-1');
      plains_2 = await loadScene('plains-2');
      plains_3 = await loadScene('plains-3');
      plains_4 = await loadScene('plains-4');
      mountains_1 = await loadScene('mountains-1');
      mountains_2 = await loadScene('mountains-2');
      mountains_3 = await loadScene('mountains-3');
      mountains_4 = await loadScene('mountains-4');
      outpost_1 = await loadScene('outpost-1');
      shrine_1 = await loadScene('shrine-1');
      empty = Scene(
          name: 'empty',
          gameObjects: [],
          grid: generate_grid_empty(
              zHeight: 1,
              rows: 10,
              columns: 10
          ),
      );
      print("Loading dark age scenes finished");
  }
}