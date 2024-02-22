import 'package:amulet_engine/isometric/classes/gameobject.dart';

List<GameObject> copyGameObjects(List<GameObject> values) =>
    List.generate(values.length, (i) => values[i].copy())
        .toList(growable: true);