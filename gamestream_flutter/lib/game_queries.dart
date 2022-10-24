
import 'dart:math';

import 'package:bleed_common/library.dart';

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

   static bool inBoundsVector3(Vector3 vector3){
     if (vector3.x < 0) return false;
     if (vector3.y < 0) return false;
     if (vector3.z < 0) return false;
     if (vector3.x >= GameState.nodesLengthRow) return false;
     if (vector3.y >= GameState.nodesLengthColumn) return false;
     if (vector3.z >= GameState.nodesLengthZ) return false;
     return true;
   }


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

   static double getDistanceFromMouse(Vector3 value) =>
     Engine.distanceFromMouse(value.renderX, value.renderY);

   static int getClosestByType({required int radius, required int type}){
     final minRow = max(GameState.player.indexRow - radius, 0);
     final maxRow = min(GameState.player.indexRow + radius, GameState.nodesTotalRows - 1);
     final minColumn = max(GameState.player.indexColumn - radius, 0);
     final maxColumn = min(GameState.player.indexColumn + radius, GameState.nodesTotalColumns - 1);
     final minZ = max(GameState.player.indexZ - radius, 0);
     final maxZ = min(GameState.player.indexZ + radius, GameState.nodesTotalZ - 1);
     var closest = 99999;
     for (var z = minZ; z <= maxZ; z++){
       for (var row = minRow; row <= maxRow; row++){
         for (var column = minColumn; column <= maxColumn; column++){
           if (GameQueries.gridNodeZRCType(z, row, column) != type) continue;
           final distance = GameState.player.getGridDistance(z, row, column);
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
     return (windLineRow - windLineColumn) * tileSizeHalf;
   }

   static int getNodeIndexV3(Vector3 vector3) =>
       GameState.getNodeIndexZRC(
         vector3.indexZ,
         vector3.indexRow,
         vector3.indexColumn,
       );

   static int getNodeIndexBelowV3(Vector3 vector3) =>
       GameState.getNodeIndexZRC(
         vector3.indexZ - 1,
         vector3.indexRow,
         vector3.indexColumn,
       );

   static bool isInboundV3(Vector3 vector3) =>
       GameQueries.isInboundZRC(vector3.indexZ, vector3.indexRow, vector3.indexColumn);

   static int getWindAtV3(Vector3 vector3) =>
       GameState.nodesWind[getNodeIndexV3(vector3)];

}