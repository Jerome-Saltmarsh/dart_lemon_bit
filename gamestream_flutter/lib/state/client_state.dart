
import 'package:gamestream_flutter/library.dart';

class ClientState {
  static var inventoryReads = Watch(0, onChanged: ClientEvents.onInventoryReadsChanged);
}