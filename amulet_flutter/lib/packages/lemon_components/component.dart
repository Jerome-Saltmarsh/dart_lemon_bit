import 'package:shared_preferences/shared_preferences.dart';

abstract class Component {
  /// used to initialize the component.
  /// It is not safe to refer to other components inside onComponentInit
  /// as it must be assumed that they have not finished initializing yet
  Future onComponentInit(SharedPreferences sharedPreferences);
  /// called when the application throws an error
  void onComponentError(Object error, StackTrace stack);
  /// called once all components have finished initializing.
  /// It is safe to call other components from onComponentsInitialized
  void onComponentReady();

  void onComponentDispose();
}