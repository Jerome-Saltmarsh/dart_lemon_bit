
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_library.dart';

class GameQueries {

   static int getNodeTypeBelow(int index){
     if (index < GameState.nodesArea) return NodeType.Boundary;
     final indexBelow = index - GameState.nodesArea;
     if (indexBelow >= GameState.nodesTotal) return NodeType.Boundary;
     return GameState.nodesType[indexBelow];
   }

   static int getNodeIndexBelow(int index) => index - GameState.nodesArea;

   static bool isInboundZRC(int z, int row, int column){
     if (z < 0) return false;
     if (z >= GameState.nodesTotalZ) return false;
     if (row < 0) return false;
     if (row >= GameState.nodesTotalRows) return false;
     if (column < 0) return false;
     if (column >= GameState.nodesTotalColumns) return false;
     return true;
   }
}