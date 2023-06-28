import 'behavior_node.dart';
import 'condition.dart';

class ConditionNodeAny implements BehaviorNode {
  final List<Condition> conditions;

  ConditionNodeAny(this.conditions);

  @override
  bool execute() {
    for (final condition in conditions){
      if (condition()) return true;
    }
    return false;
  }
}
