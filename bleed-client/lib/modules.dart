
import 'core/module.dart';

final modules = _Modules();

class _Modules {
  final core = CoreModule();
}

get core => modules.core;