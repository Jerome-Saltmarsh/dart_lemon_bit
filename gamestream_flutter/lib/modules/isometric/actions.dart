import 'package:gamestream_flutter/modules/isometric/properties.dart';
import 'package:gamestream_flutter/modules/isometric/queries.dart';
import 'package:gamestream_flutter/modules/isometric/state.dart';

class IsometricActions {

  // final IsometricState state;
  final IsometricQueries queries;
  final IsometricProperties properties;

  IsometricActions(this.queries, this.properties);

}