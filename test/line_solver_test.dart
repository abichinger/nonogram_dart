import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/nonogram_dart.dart';
import 'package:nonogram_dart/src/description.dart' as desc;

void main() {
  const b = Colors.black;
  const w = Colors.white;
  group('DescriptionIterator', () {
    group('iterate possible lines of a description', () {
      test('3', () {
        const d = desc.Description([
          desc.Stroke(b, 3),
        ]);

        var expected = [
          [b, b, b, w, w],
          [w, b, b, b, w],
          [w, w, b, b, b],
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
          desc.Stroke(b, 3),
        ]);

        var line = ListLine([null, 1, null, null, null]);

        var expected = [
          [b, b, b, w, w],
          [w, b, b, b, w],
        ];

        var i = 0;
        for (var line in d.iterPossible(line)) {
          expect(line, expected[i]);
          i++;
        }
      });

      test('1 1', () {
        const d = desc.Description([
          desc.Stroke(b, 1),
          desc.Stroke(b, 1),
        ]);

        var line = ListLine([null, 1, null, null, null]);

        var expected = [
          [w, b, w, b, w],
          [w, b, w, w, b],
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
        desc.Stroke(b, 1),
        desc.Stroke(b, 2),
      ]);

      final lineDesc = LineDescription.from(d);
      expect(lineDesc.toLine(4), [b, w, b, b]);
      expect(lineDesc.toLine(5), [b, w, b, b, w]);
    });
  });

  group('PermutationSover', () {
    test('4 n ■ n n n n', () {
      const d = desc.Description([
        desc.Stroke(b, 4),
      ]);

      var line = ListLine([null, b, null, null, null, null]);

      final solver = PermutationSolver(line, d);
      var steps = solver.getSteps()..sort((a, b) => a.i.compareTo(b.i));
      expect(steps.length, 3);
      expect(steps.map((s) => s.i), [2, 3, 5]);
      expect(steps.map((s) => s.color), [b, b, w]);
    });

    test('1 5 n □ ■ ■ ■ ■ ■ □', () {
      const d = desc.Description([
        desc.Stroke(b, 1),
        desc.Stroke(b, 5),
      ]);

      var line = ListLine([null, w, b, b, b, b, b, w]);

      final solver = PermutationSolver(line, d);
      var steps = solver.getSteps();
      expect(steps.length, 1);
    });

    test('1 3 n n n n n', () {
      const d = desc.Description([
        desc.Stroke(b, 1),
        desc.Stroke(b, 3),
      ]);

      var line = ListLine([null, null, null, null, null]);

      final solver = PermutationSolver(line, d);
      var steps = solver.getSteps();
      expect(steps.length, 5);
    });
  });
}
