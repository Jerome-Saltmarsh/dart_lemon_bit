
import 'component.dart';
import 'updatable.dart';

class ComponentContainer {
  final components = <dynamic>[];
  final updatable = <Updatable>[];
  var initializing = false;
  var initialized = false;

  Future init(sharedPreferences) async {
    if (initializing || initialized) return;
    print('component_container.initializing = true');
    initializing = true;

    for (final component in components){
      if (component is Updatable) {
        updatable.add(component);
      }
    }

    for (final component in components){
      if (component is Component)
        await component.onComponentInit(sharedPreferences);
    }

    for (final component in components){
      if (component is Component)
        component.onComponentReady();
    }

    initializing = false;
    initialized = true;
    print('component_container.initialized = true');
  }

  void update(double delta) {
    for (final updatable in updatable) {
      updatable.onComponentUpdate();
    }
  }

  void onError(Object error, StackTrace stack){
    for (final component in components){
      if (component is Component)
        component.onComponentError(error, stack);
    }
  }

  void onDispose(){
    for (final component in components) {
      if (component is Component)
        component.onComponentDispose();
    }
  }
}