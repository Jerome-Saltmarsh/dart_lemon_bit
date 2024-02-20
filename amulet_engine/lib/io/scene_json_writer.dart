
import 'package:amulet_engine/isometric/classes/scene.dart';
import 'package:amulet_engine/isometric/instances/encoder.dart';
import 'package:lemon_json/src.dart';

Json writeSceneToJson(Scene scene){
  final json = Json();
  json['node_types'] = encoder.encode(scene.nodeTypes);
  json['node_orientations'] = encoder.encode(scene.nodeOrientations);
  json['variations'] = encoder.encode(scene.variations);
  json['marks'] = encoder.encode(scene.marks);
  json['keys'] = scene.keys;
  json['locations'] = scene.locations;
  return json;
}