
import 'core/module.dart';
import 'website/module.dart';

final modules = _Modules();

get core => modules.core;
get website => modules.website;

class _Modules {
  final core = CoreModule();
  final website = WebsiteModule();
}
