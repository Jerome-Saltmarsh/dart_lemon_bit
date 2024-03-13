
enum IsometricEditorGameObjectRequest {
  Add,
  Select,
  Deselect,
  Translate,
  Delete,
  Set_Type,
  Move_To_Mouse,
  Toggle_Hitable,
  Toggle_Fixed,
  Toggle_Collectable,
  Toggle_Physical,
  // Toggle_Persistable,
  Toggle_Gravity,
  Toggle_Interactable,
  Toggle_Collidable,
  Duplicate,
}

const gameObjectRequests = IsometricEditorGameObjectRequest.values;