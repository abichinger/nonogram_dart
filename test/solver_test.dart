import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/src/description.dart' as desc;
import 'package:nonogram_dart/src/nonogram.dart';
import 'package:nonogram_dart/src/solver/solver.dart';

import 'test_util.dart';

void main() {
  const b = desc.Colors.black;
  const w = desc.Colors.white;
  const red = 0xFFFF0000;
  const blue = 0xFF0000FF;
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
        [w, b, b, b, b],
        [b, w, b, b, b],
        [w, b, b, w, w],
        [b, w, w, w, w],
        [b, b, b, w, b],
      ];

      final solver = LogicalSolver.empty(puzzle);
      solver.solve();

      expectGrid(solver.grid, expected);
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

    test('solve (logic color puzzle)', () {
      final grid =
          Grid.fromPng(File('test/puzzles/target.png').readAsBytesSync());
      final puzzle = grid.toNonogram();

      expect(
        puzzle.rows[0],
        const desc.Description([
          desc.Stroke(red, 3),
        ]),
      );
      expect(
        puzzle.rows[1],
        const desc.Description([
          desc.Stroke(red, 1),
          desc.Stroke(blue, 3),
          desc.Stroke(red, 1),
        ]),
      );
      expect(
        puzzle.rows[2],
        const desc.Description([
          desc.Stroke(red, 1),
          desc.Stroke(red, 1),
          desc.Stroke(red, 1),
        ]),
      );

      final solver = LogicalSolver.empty(puzzle);
      solver.solve();

      expect(solver.grid.toList(), grid.toList());
    });

    test('solve (invader monochrome)', () {
      final grid =
          Grid.fromPng(File('test/puzzles/invader.png').readAsBytesSync())
              .toMonochrome();
      final puzzle = grid.toNonogram();

      final solver = GuessingSolver.empty(puzzle);
      expect(solver.toList().length, 1);
      expect(puzzle.isLineSolveable(), true);
      expect(solver.grid.toList(), grid.toList());
    });
  });
}
