import 'dart:math';

import 'package:nonogram_dart/src/nonogram.dart';

class GridConstraint {}

class Generator {
  static Nonogram monochrome(int width, int height, {int? seed}) {
    final grid = Grid.empty(width: width, height: height);
    final rnd = Random(seed);

    for (var i = 0; i < grid.height; i++) {
      for (var j = 0; j < grid.width; j++) {
        grid.set(i, j, rnd.nextInt(2));
      }
    }

    return grid.toNonogram();
  }
}
