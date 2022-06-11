
import 'dart:convert';

import 'package:typedef/json.dart';

import '../classes/Scene.dart';

String convertSceneToJson(Scene scene){
   final json = Json();
   json['grid-z'] = scene.gridHeight;
   json['grid-rows'] = scene.gridRows;
   json['grid-columns'] = scene.gridColumns;
   final grid = <int> [];
   for (var z = 0; z < scene.gridHeight; z++){
      for (var row = 0; row < scene.gridRows; row++){
          for (var column = 0; column < scene.gridColumns; column++){
              grid.add(scene.grid[z][row][column].type);
          }
      }
   }
   json['grid'] = grid;
   return jsonEncode(json);
}