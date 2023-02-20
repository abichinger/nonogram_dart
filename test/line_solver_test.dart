import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/src/description.dart' as desc;
import 'package:nonogram_dart/src/nonogram.dart';
import 'package:nonogram_dart/src/solver/line_solver.dart';

void main() {
  group('DescriptionIterator', () {
    group('iterate possible lines of a description', () {
      test('3', () {
        const d = desc.Description([
          desc.Stroke(1, 3),
        ]);

        var expected = [
          [1, 1, 1, 0, 0],
          [0, 1, 1, 1, 0],
          [0, 0, 1, 1, 1],
        ];

        var i = 0;
        for (var line in d.iter(5)) {
          expect(line, expected[i]);
          i++;
        }
      });
    });
  });

  group('PossibleLineIterator', () {
    group('iterate possible lines', () {
      test('3', () {
        const d = desc.Description([
          desc.Stroke(1, 3),
        ]);

        var line = ListLine([null, 1, null, null, null]);

        var expected = [
          [1, 1, 1, 0, 0],
          [0, 1, 1, 1, 0],
        ];

        var i = 0;
        for (var line in d.iterPossible(line)) {
          expect(line, expected[i]);
          i++;
        }
      });

      test('1 1', () {
        const d = desc.Description([
          desc.Stroke(1, 1),
          desc.Stroke(1, 1),
        ]);

        var line = ListLine([null, 1, null, null, null]);

        var expected = [
          [0, 1, 0, 1, 0],
          [0, 1, 0, 0, 1],
        ];

        var i = 0;
        for (var line in d.iterPossible(line)) {
          expect(line, expected[i]);
          i++;
        }
      });
    });
  });

  group('LineDescription', () {
    test('toLine', () {
      const d = desc.Description([
        desc.Stroke(1, 1),
        desc.Stroke(1, 2),
      ]);

      final lineDesc = LineDescription.from(d);
      expect(lineDesc.toLine(4), [1, 0, 1, 1]);
      expect(lineDesc.toLine(5), [1, 0, 1, 1, 0]);
    });
  });

  group('PermutationSover', () {
    test('getSteps', () {
      const d = desc.Description([
        desc.Stroke(1, 4),
      ]);

      var line = ListLine([null, 1, null, null, null, null]);

      final solver = PermutationSolver(line, d);
      var steps = solver.getSteps()..sort((a, b) => a.i.compareTo(b.i));
      expect(steps.length, 3);
      expect(steps.map((s) => s.i), [2, 3, 5]);
      expect(steps.map((s) => s.color), [1, 1, 0]);
    });
  });
}
