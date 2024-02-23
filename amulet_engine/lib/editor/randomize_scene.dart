
import 'package:lemon_math/src.dart';

import '../common/src.dart';
import '../isometric/src.dart';

void randomizeScene(Scene scene){
  final totalNodes = scene.volume;
  final nodeTypes = scene.nodeTypes;
  final nodeVariations = scene.variations;
  for (var i = 0; i < totalNodes; i++){
      final nodeType = nodeTypes[i];

      if (nodeType == NodeType.Tree_Bottom){
        nodeVariations[i] = randomInt(0, 6);
        continue;
      }

      if (nodeType == NodeType.Grass) {
        if (randomChance(0.05)){
          nodeVariations[i] = 2;
        } else {
           nodeVariations[i] = randomItem(const[0, 1]);
        }
        continue;
      }
  }
}