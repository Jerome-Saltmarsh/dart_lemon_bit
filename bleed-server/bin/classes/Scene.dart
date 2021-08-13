
import '../classes.dart';
import '../enums.dart';
import 'Block.dart';

class Scene {
  List<GameObject> objects = [];
  final List<List<Tile>> tiles;
  List<Block> blocks = [];

  Scene(this.objects, this.tiles, this.blocks);
}

extension SceneFunctions on Scene {
  void sortBlocks(){
    blocks.sort((a, b) => a.leftX < b.leftX ? -1 : 1);
  }

  void addBlock(double x, double y, double width, double length){
    blocks.add(Block.build(x, y, width, length));
  }
}