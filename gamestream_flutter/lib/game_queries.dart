
import 'package:bleed_common/library.dart';

import 'isometric/grid_state_util.dart';
import 'library.dart';

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

   static bool isVisibleV3(Vector3 vector) =>
       inBoundsVector3(vector) ? GameState.nodesVisible[getGridNodeIndexV3(vector)] : true;

   static int getGridNodeIndexV3(Vector3 vector3) =>
       getGridNodeIndexXYZ(
           vector3.x, vector3.y, vector3.z
       );

   static int getGridNodeIndexXYZ(double x, double y, double z) =>
       GameState.getNodeIndexZRC(
         z ~/ tileSizeHalf,
         x ~/ tileSize,
         y ~/ tileSize,
       );

   static int gridNodeXYZTypeSafe(double x, double y, double z) {
     if (x < 0) return NodeType.Boundary;
     if (y < 0) return NodeType.Boundary;
     if (z < 0) return NodeType.Boundary;
     if (x >= GameState.nodesLengthRow) return NodeType.Boundary;
     if (y >= GameState.nodesLengthColumn) return NodeType.Boundary;
     if (z >= GameState.nodesLengthZ) return NodeType.Boundary;
     return gridNodeXYZType(x, y, z);
   }

   static int gridNodeXYZType(double x, double y, double z) =>
       GameState.nodesType[gridNodeXYZIndex(x, y, z)];

   static bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
       NodeType.isRainOrEmpty(GameState.nodesType[GameState.getNodeIndexZRC(z, row, column)]);

   static int gridNodeZRCTypeSafe(int z, int row, int column) {
     if (z < 0) return NodeType.Boundary;
     if (row < 0) return NodeType.Boundary;
     if (column < 0) return NodeType.Boundary;
     if (z >= GameState.nodesTotalZ) return NodeType.Boundary;
     if (row >= GameState.nodesTotalRows) return NodeType.Boundary;
     if (column >= GameState.nodesTotalColumns) return NodeType.Boundary;
     return gridNodeZRCType(z, row, column);
   }

   static int gridNodeZRCType(int z, int row, int column) =>
       GameState.nodesType[GameState.getNodeIndexZRC(z, row, column)];


   static int gridNodeXYZIndex(double x, double y, double z) =>
       GameState.getNodeIndexZRC(
         z ~/ tileSizeHalf,
         x ~/ tileSize,
         y ~/ tileSize,
       );
}