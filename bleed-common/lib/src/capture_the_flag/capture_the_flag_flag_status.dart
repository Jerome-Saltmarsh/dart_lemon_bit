
class CaptureTheFlagFlagStatus {
   static const At_Base           = 1;
   static const Carried_By_Enemy  = 2;
   static const Carried_By_Ally  = 3;
   static const Dropped           = 4;
   static const Respawning        = 5;

   static String getName(int value)=> switch (value) {
          At_Base => 'At_Base',
          Carried_By_Enemy => 'Carried_By_Enemy',
          Carried_By_Ally => 'Carried_By_Allie',
          Dropped => 'Dropped',
          Respawning => 'Respawning',
          _ => 'unknown-$value'
       };
}