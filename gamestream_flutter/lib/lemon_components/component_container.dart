
import 'component.dart';
import 'updatable.dart';

class ComponentContainer {
  final components = <dynamic>[];
  final updatable = <Updatable>[];

  Future init(sharedPreferences) async {
    print('iocContainer.init()');

    for (final component in components){
      if (component is Updatable) {
        updatable.add(component);
      }
    }

    for (final component in components){
      if (component is Component)
        await component.initializeComponent(sharedPreferences);
    }

    for (final component in components){
      if (component is Component)
        component.onComponentsInitialized();
    }
  }

  void update() {
    for (final updatable in updatable) {
      updatable.onComponentUpdate();
    }
  }

  void onError(Object error, StackTrace stack){
    for (final component in components){
      if (component is Component)
        component.onError(error, stack);
    }
  }
}