import 'package:test/test.dart';
import 'package:nonogram_dart/nonogram_dart.dart';

void main() {
  const b = Colors.black;
  const w = Colors.white;
  group('GridGenerator', () {
    test('apply', () {
      final gen = GridGenerator(width: 10, height: 10, colors: {b, w});
      gen.apply([RandomizeAll()]);
      final grid = gen.getGrid();

      expect(grid.height, 10);
      expect(grid.width, 10);
      expect(grid.toNonogram().colors, {b});
    });
  });
}
