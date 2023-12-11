
import '../packages/isomeric_engine.dart';
import '../utils/list_extensions.dart';

void randomizeScene(Scene scene){
  final totalNodes = scene.volume;
  final nodeTypes = scene.types;
  final nodeVariations = scene.variations;
  for (var i = 0; i < totalNodes; i++){
      final nodeType = nodeTypes[i];
      if (nodeType != NodeType.Grass) {
        continue;
      }
      
      if (randomChance(0.05)){
        nodeVariations[i] = 2;
      } else {
        nodeVariations[i] = const[0, 1].random();
      }
  }
}