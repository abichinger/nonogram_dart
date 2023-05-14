import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/src/generate.dart';

void main() {
  group('Generator', () {
    test('monochrome', () {
      final puzzle = Generator.monochrome(5, 5);
      expect(puzzle.columns.length, 5);
      expect(puzzle.rows.length, 5);
    });
  });
}
