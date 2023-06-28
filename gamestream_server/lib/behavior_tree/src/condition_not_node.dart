import 'behavior_node.dart';
import 'condition.dart';

class ConditionNotNode implements BehaviorNode {
  final Condition condition;

  ConditionNotNode(this.condition);

  @override
  bool execute() => !condition();
}
