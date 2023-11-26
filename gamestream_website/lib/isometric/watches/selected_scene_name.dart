import 'package:lemon_watch/watch.dart';

final selectedSceneName = Watch<String?>(null);

void selectSceneName(String value){
  selectedSceneName.value = value;
}

