
enum IsometricEditorGameObjectRequest {
  Add,
  Select,
  Deselect,
  Translate,
  Delete,
  Set_Type,
  Move_To_Mouse,
  Toggle_Strikable,
  Toggle_Fixed,
  Toggle_Collectable,
  Toggle_Physical,
  Toggle_Persistable,
  Toggle_Gravity,
  Duplicate,
}

const gameObjectRequests = IsometricEditorGameObjectRequest.values;