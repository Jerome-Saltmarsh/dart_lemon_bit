
import '../classes.dart';
import '../enums.dart';
import 'Block.dart';
import 'Collectable.dart';

class Scene {
  List<GameObject> objects = [];
  final List<List<Tile>> tiles;
  List<Block> blocks = [];
  List<Collectable> collectables;

  Scene(this.objects, this.tiles, this.blocks, this.collectables);
}

extension SceneFunctions on Scene {
  void sortBlocks(){
    blocks.sort((a, b) => a.leftX < b.leftX ? -1 : 1);
  }

  void addBlock(double x, double y, double width, double length){
    blocks.add(Block.build(x, y, width, length));
  }
}