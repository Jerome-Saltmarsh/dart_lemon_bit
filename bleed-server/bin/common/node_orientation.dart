

class NodeOrientation {
   static const None = 0;
   static const North = 1;
   static const East = 2;
   static const South = 3;
   static const West = 4;
   static const Corner_Left = 5;
   static const Corner_Top = 6;
   static const Corner_Right = 7;
   static const Corner_Bottom = 8;
   static const Solid = 9;
   static const Row_1 = 10;
   static const Row_2 = 11;
   static const Column_1 = 12;
   static const Column_2 = 13;

   static bool isSlope(int value) =>
      value == North ||
      value == East ||
      value == South ||
      value == West ;
}