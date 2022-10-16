
import 'actions.dart';
import 'properties.dart';


/// Controls the flow of the entire application
class CoreModule {
  late final properties;
  final actions = CoreActions();

  CoreModule(){
    properties = CoreProperties();
  }
}