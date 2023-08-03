import 'package:shared_preferences/shared_preferences.dart';

abstract class Component {
  Future initializeComponent(SharedPreferences sharedPreferences) async {  }
  void onComponentsInitialized(){  }
  void onError(Object error, StackTrace stack) {}
}