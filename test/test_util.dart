import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/nonogram_dart.dart';

void expectGrid(Grid grid, List<List<int?>> expected) {
  for (var i = 0; i < grid.height; i++) {
    for (var j = 0; j < grid.width; j++) {
      expect(grid.get(i, j), expected[i][j]);
    }
  }
}
