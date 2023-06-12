// Behavior tree node interface
abstract class BehaviorNode {
  bool execute();
}

// Selector node: Executes child nodes until one succeeds
class SelectorNode implements BehaviorNode {
  final List<BehaviorNode> children;

  SelectorNode(this.children);

  @override
  bool execute() {
    for (var child in children) {
      if (child.execute()) {
        return true;
      }
    }
    return false;
  }
}

// Sequence node: Executes child nodes until one fails
class SequenceNode implements BehaviorNode {
  final List<BehaviorNode> children;

  SequenceNode(this.children);

  @override
  bool execute() {
    for (var child in children) {
      if (!child.execute()) {
        return false;
      }
    }
    return true;
  }
}

// Condition node: Checks a condition and returns true or false
typedef Condition = bool Function();

class ConditionNode implements BehaviorNode {
  final Condition condition;

  ConditionNode(this.condition);

  @override
  bool execute() {
    return condition();
  }
}

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


class ConditionNotNode implements BehaviorNode {
  final Condition condition;

  ConditionNotNode(this.condition);

  @override
  bool execute() => !condition();
}


// Action node: Performs an action
typedef Action = void Function();

class ActionNode implements BehaviorNode {
  final Action action;

  ActionNode(this.action);

  @override
  bool execute() {
    action();
    return true;
  }
}

// NPC class
class NPC {
  final BehaviorNode behaviorTree;

  NPC(this.behaviorTree);

  void update() {
    behaviorTree.execute();
  }
}

// Example usage

// Condition: Check if enemy flag is captured


// ... Implement other conditions and actions ...

// void main() {
//   // Create the behavior tree for the NPC
//   var behaviorTree = SelectorNode([
//     SequenceNode([
//       ConditionNode(isEnemyFlagCaptured),
//       ActionNode(moveToEnemyFlag),
//     ]),
//     SequenceNode([
//       ConditionNode(isEnemyFlagNear),
//       ActionNode(moveToEnemyFlag),
//     ]),
//     ActionNode(patrolBaseArea),
//   ]);
//
//   // Create an NPC with the behavior tree
//   var npc = NPC(behaviorTree);
//
//   // Update the NPC's behavior
//   npc.update();
// }
