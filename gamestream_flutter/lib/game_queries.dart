
import 'dart:math';

import 'library.dart';

class GameQueries {

   static int getNodeTypeBelow(int index){
     if (index < GameNodes.area) return NodeType.Boundary;
     final indexBelow = index - GameNodes.area;
     if (indexBelow >= GameNodes.total) return NodeType.Boundary;
     return GameNodes.nodeTypes[indexBelow];
   }

   static int getNodeIndexBelow(int index) => index - GameNodes.area;

   static bool isInboundZRC(int z, int row, int column){
     if (z < 0) return false;
     if (z >= GameNodes.totalZ) return false;
     if (row < 0) return false;
     if (row >= GameNodes.totalRows) return false;
     if (column < 0) return false;
     if (column >= GameNodes.totalColumns) return false;
     return true;
   }

   // static bool isVisibleV3(Vector3 vector) =>
   //     inBoundsVector3(vector) ? GameNodes.nodeVisible[getNodeIndexV3(vector)] != Visibility.Invisible : true;

   // static bool isVisibleXYZ(double x, double y, double z) =>
   //     inBounds(x, y, z) ? GameNodes.nodeVisible[getNodeIndex(x, y, z)] != Visibility.Invisible : true;

   static bool inBoundsVector3(Vector3 vector3) =>
       inBounds(vector3.x, vector3.y, vector3.z);

   static bool inBounds(double x, double y, double z){
     if (x < 0) return false;
     if (y < 0) return false;
     if (z < 0) return false;
     if (x >= GameNodes.lengthRows) return false;
     if (y >= GameNodes.lengthColumns) return false;
     if (z >= GameNodes.lengthZ) return false;
     return true;
   }

   static int getNodeIndex(double x, double y, double z) =>
       GameState.getNodeIndexZRC(
         z ~/ Node_Size_Half,
         x ~/ Node_Size,
         y ~/ Node_Size,
       );

   static int getNodeIndexV3(Vector3 vector3) =>
       GameState.getNodeIndexZRC(
         vector3.indexZ,
         vector3.indexRow,
         vector3.indexColumn,
       );


   static int gridNodeXYZTypeSafe(double x, double y, double z) {
     if (x < 0) return NodeType.Boundary;
     if (y < 0) return NodeType.Boundary;
     if (z < 0) return NodeType.Boundary;
     if (x >= GameNodes.lengthRows) return NodeType.Boundary;
     if (y >= GameNodes.lengthColumns) return NodeType.Boundary;
     if (z >= GameNodes.lengthZ) return NodeType.Boundary;
     return gridNodeXYZType(x, y, z);
   }

   static int gridNodeXYZType(double x, double y, double z) =>
       GameNodes.nodeTypes[gridNodeXYZIndex(x, y, z)];

   static bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
       NodeType.isRainOrEmpty(GameNodes.nodeTypes[GameState.getNodeIndexZRC(z, row, column)]);

   static int gridNodeZRCTypeSafe(int z, int row, int column) {
     if (z < 0) return NodeType.Boundary;
     if (row < 0) return NodeType.Boundary;
     if (column < 0) return NodeType.Boundary;
     if (z >= GameNodes.totalZ) return NodeType.Boundary;
     if (row >= GameNodes.totalRows) return NodeType.Boundary;
     if (column >= GameNodes.totalColumns) return NodeType.Boundary;
     return gridNodeZRCType(z, row, column);
   }

   static int gridNodeZRCType(int z, int row, int column) =>
       GameNodes.nodeTypes[GameState.getNodeIndexZRC(z, row, column)];


   static int gridNodeXYZIndex(double x, double y, double z) =>
       GameState.getNodeIndexZRC(
         z ~/ Node_Size_Half,
         x ~/ Node_Size,
         y ~/ Node_Size,
       );

   static double getDistanceFromMouse(Vector3 value) =>
     Engine.distanceFromMouse(value.renderX, value.renderY);


   // TODO REFACTOR
   static int getClosestByType({required int radius, required int type}){
     final minRow = max(GamePlayer.position.indexRow - radius, 0);
     final maxRow = min(GamePlayer.position.indexRow + radius, GameNodes.totalRows - 1);
     final minColumn = max(GamePlayer.position.indexColumn - radius, 0);
     final maxColumn = min(GamePlayer.position.indexColumn + radius, GameNodes.totalColumns - 1);
     final minZ = max(GamePlayer.position.indexZ - radius, 0);
     final maxZ = min(GamePlayer.position.indexZ + radius, GameNodes.totalZ - 1);
     var closest = 99999;
     for (var z = minZ; z <= maxZ; z++){
       for (var row = minRow; row <= maxRow; row++){
         for (var column = minColumn; column <= maxColumn; column++){
           if (GameQueries.gridNodeZRCType(z, row, column) != type) continue;
           final distance = GamePlayer.position.getGridDistance(z, row, column);
           if (distance > closest) continue;
           closest = distance;
         }
       }
     }
     return closest;
   }

   static double get windLineRenderX {
     var windLineColumn = 0;
     var windLineRow = 0;
     if (GameState.windLine < GameNodes.totalRows){
       windLineColumn = 0;
       windLineRow = GameNodes.totalRows - GameState.windLine - 1;
     } else {
       windLineRow = 0;
       windLineColumn = GameState.windLine - GameNodes.totalRows + 1;
     }
     return (windLineRow - windLineColumn) * Node_Size_Half;
   }

   static int getNodeIndexBelowV3(Vector3 vector3) =>
       GameState.getNodeIndexZRC(
         vector3.indexZ - 1,
         vector3.indexRow,
         vector3.indexColumn,
       );

   static bool isInboundV3(Vector3 vector3) =>
       GameQueries.isInboundZRC(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

   // static int getWindAtV3(Vector3 vector3) =>
   //     GameNodes.nodeWind[getNodeIndexV3(vector3)];

}