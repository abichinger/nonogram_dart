import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/src/nonogram.dart';
import 'package:nonogram_dart/src/solver/solver.dart';

void main() {
  group('Solver', () {
    test('solve (logic puzzle)', () {
      final puzzle = Nonogram.monochrome([
        [4],
        [1, 3],
        [2],
        [1],
        [3, 1],
      ], [
        [1, 2],
        [1, 1, 1],
        [3, 1],
        [2],
        [2, 1],
      ]);

      final expected = [
        [0, 1, 1, 1, 1],
        [1, 0, 1, 1, 1],
        [0, 1, 1, 0, 0],
        [1, 0, 0, 0, 0],
        [1, 1, 1, 0, 1],
      ];

      final solver = LogicalSolver.empty(puzzle);
      solver.solve();

      for (var i = 0; i < puzzle.height; i++) {
        for (var j = 0; j < puzzle.width; j++) {
          expect(solver.grid.get(i, j), expected[i][j]);
        }
      }

      expect(puzzle.isLineSolveable(), true);
    });

    test('solve (multiple solutions)', () {
      final puzzle = Nonogram.monochrome([
        [4],
        [3],
        [2, 1],
        [1, 3],
        [1, 1],
        [3],
        [2]
      ], [
        [4],
        [3],
        [2, 1],
        [1, 3],
        [1, 1],
        [3],
        [2],
      ]);

      final solver = GuessingSolver.empty(puzzle);
      solver.solve();

      final solutions = solver.toList();
      expect(solutions.length, 2);

      expect(puzzle.isLineSolveable(), false);
    });

    test('solve (no solution)', () {
      final puzzle = Nonogram.monochrome([
        [2],
        [2],
      ], [
        [1],
        [1],
      ]);

      final solver = GuessingSolver.empty(puzzle);
      solver.solve();

      final solutions = solver.toList();
      expect(solutions.length, 0);

      expect(puzzle.isLineSolveable(), false);
    });
  });
}
