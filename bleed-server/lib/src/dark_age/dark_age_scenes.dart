import 'dart:typed_data';

import 'package:bleed_server/gamestream.dart';
import 'package:bleed_server/src/io/write_scene_to_file.dart';

import '../io/load_scene.dart';

final darkAgeScenes = DarkAgeScenes();

class DarkAgeScenes {
  late Scene village;
  late Scene dungeon_1;
  late Scene skirmish_1;
  late Scene skirmish_2;
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
  late Scene cemetery_1;
  late Scene plains_4;
  late Scene mountains_1;
  late Scene mountains_2;
  late Scene mountains_3;
  late Scene mountains_4;
  late Scene empty;
  late Scene outpost_1;
  late Scene shrine_1;
  late Scene suburbs_01;

  List<Scene> values = [];

  Future load() async {
      print('Loading dark age scenes');
      final start = DateTime.now();
      farm = await loadScene('farm');
      farmA = await loadScene('farm-a');
      farmB = await loadScene('farm-b');
      village = await loadScene('village');
      skirmish_1 = await loadScene('skirmish-1');
      skirmish_2 = await loadScene('skirmish-2');
      forest = await loadScene('forest');
      forest_2 = await loadScene('forest-b');
      forest_3 = await loadScene('forest-3');
      forest_4 = await loadScene('forest-4');
      mountainShrine = await loadScene('mountain-shrine');
      lake = await loadScene('lake');
      town = await loadScene('town');
      plains_1 = await loadScene('plains-1');
      plains_2 = await loadScene('plains-2');
      cemetery_1 = await loadScene('plains-3');
      plains_4 = await loadScene('plains-4');
      mountains_1 = await loadScene('mountains-1');
      mountains_2 = await loadScene('mountains-2');
      mountains_3 = await loadScene('mountains-3');
      mountains_4 = await loadScene('mountains-4');
      shrine_1 = await loadScene('shrine-1');
      suburbs_01 = await loadScene('suburbs_01');
      final ms = DateTime.now().difference(start).inMilliseconds;
      print("scenes took $ms ms to load");

      values.add(farm);
      values.add(farmA);
      values.add(farmB);
      values.add(village);
      values.add(skirmish_1);
      values.add(skirmish_2);
      values.add(forest);
      values.add(forest_2);
      values.add(forest_3);
      values.add(forest_4);
      values.add(mountainShrine);
      values.add(lake);
      values.add(town);
      values.add(plains_1);
      values.add(plains_2);
      values.add(cemetery_1);
      values.add(plains_4);
      values.add(mountains_1);
      values.add(mountains_2);
      values.add(mountains_3);
      values.add(mountains_4);
      values.add(shrine_1);

      // saveAllToFile();

    final emptyList = Uint8List(0);
      empty = Scene(
          name: 'empty',
          gameObjects: [],
          gridColumns: 0,
          gridHeight: 0,
          gridRows: 0,
          nodeOrientations: emptyList,
          nodeTypes: emptyList,
          spawnPoints: Uint16List(0),
          spawnPointTypes: Uint16List(0),
          spawnPointsPlayers: Uint16List(0),
      );
      print("Loading dark age scenes finished");
  }

  void saveAllToFile(){
    values.forEach(writeSceneToFileBytes);
  }
}
