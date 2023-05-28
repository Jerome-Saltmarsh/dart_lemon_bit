
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamestream_flutter/library.dart';

class WebsiteActions {

  static void checkForLatestVersion() async {
    await saveVisitDateTime();
    GameWebsite.operationStatus.value = OperationStatus.Checking_For_Updates;
    engine.refreshPage();
  }

  static Future saveVisitDateTime() async =>
      save('visit-datetime', DateTime.now().toIso8601String());

  static Future saveVersion() async =>
      await save('version', version);

  static Future save(String key, dynamic value) async =>
      (await SharedPreferences.getInstance()).putAny(key, value);
}