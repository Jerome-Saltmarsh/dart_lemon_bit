
import 'package:bleed_client/core/build.dart';
import 'package:bleed_client/core/state.dart';

/// The core module controls the flow of the entire application
/// Sub modules
///   -- website
///   -- editor
///   -- game
final core = _CoreModule();

class _CoreModule {
  final state = CoreState();
  final build = CoreBuild();
}