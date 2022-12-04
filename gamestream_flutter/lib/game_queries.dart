
import 'dart:math';

import 'library.dart';

class GameQueries {

   static int getNodeTypeBelow(int index){
     if (index < GameState.nodesArea) return NodeType.Boundary;
     final indexBelow = index - GameState.nodesArea;
     if (indexBelow >= GameNodes.nodesTotal) return NodeType.Boundary;
     return GameNodes.nodesType[indexBelow];
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
       inBoundsVector3(vector) ? GameNodes.nodesVisible[getNodeIndexV3(vector)] : true;

   static bool inBoundsVector3(Vector3 vector3) =>
       inBounds(vector3.x, vector3.y, vector3.z);

   static bool inBounds(double x, double y, double z){
     if (x < 0) return false;
     if (y < 0) return false;
     if (z < 0) return false;
     if (x >= GameState.nodesLengthRow) return false;
     if (y >= GameState.nodesLengthColumn) return false;
     if (z >= GameState.nodesLengthZ) return false;
     return true;
   }

   // static int getGridNodeIndexV3(Vector3 vector3) =>
   //     getNodeIndex(
   //         vector3.x, vector3.y, vector3.z
   //     );

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
     if (x >= GameState.nodesLengthRow) return NodeType.Boundary;
     if (y >= GameState.nodesLengthColumn) return NodeType.Boundary;
     if (z >= GameState.nodesLengthZ) return NodeType.Boundary;
     return gridNodeXYZType(x, y, z);
   }

   static int gridNodeXYZType(double x, double y, double z) =>
       GameNodes.nodesType[gridNodeXYZIndex(x, y, z)];

   static bool gridNodeZRCTypeRainOrEmpty(int z, int row, int column) =>
       NodeType.isRainOrEmpty(GameNodes.nodesType[GameState.getNodeIndexZRC(z, row, column)]);

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
       GameNodes.nodesType[GameState.getNodeIndexZRC(z, row, column)];


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
     final maxRow = min(GamePlayer.position.indexRow + radius, GameState.nodesTotalRows - 1);
     final minColumn = max(GamePlayer.position.indexColumn - radius, 0);
     final maxColumn = min(GamePlayer.position.indexColumn + radius, GameState.nodesTotalColumns - 1);
     final minZ = max(GamePlayer.position.indexZ - radius, 0);
     final maxZ = min(GamePlayer.position.indexZ + radius, GameState.nodesTotalZ - 1);
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
     if (GameState.windLine < GameState.nodesTotalRows){
       windLineColumn = 0;
       windLineRow = GameState.nodesTotalRows - GameState.windLine - 1;
     } else {
       windLineRow = 0;
       windLineColumn = GameState.windLine - GameState.nodesTotalRows + 1;
     }
     return (windLineRow - windLineColumn) * Node_Size_Half;
   }

   // static int getNodeIndex(double x, double y, double z){
   //     final indexZ = z ~/ Node_Height;
   //
   //     return 0;
   // }

   static int getNodeIndexBelowV3(Vector3 vector3) =>
       GameState.getNodeIndexZRC(
         vector3.indexZ - 1,
         vector3.indexRow,
         vector3.indexColumn,
       );

   static bool isInboundV3(Vector3 vector3) =>
       GameQueries.isInboundZRC(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

   static int getWindAtV3(Vector3 vector3) =>
       GameNodes.nodesWind[getNodeIndexV3(vector3)];

}