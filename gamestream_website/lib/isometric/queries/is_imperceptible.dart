
import 'package:gamestream_flutter/isometric/grid.dart';

bool isImperceptible(int z, int row, int column){
      return
          !gridIsPerceptible(z, row, column)
            ||
          !gridIsPerceptible(z + 1, row, column)
            ||
          !gridIsPerceptible(z, row + 1, column + 1)
            ||
          !gridIsPerceptible(z, row - 1, column)
            ||
          !gridIsPerceptible(z, row , column - 1)
  ;
}