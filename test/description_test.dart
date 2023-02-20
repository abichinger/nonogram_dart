import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/nonogram_dart.dart';
import 'package:nonogram_dart/src/description.dart' as desc;

void main() {
  group("Description", () {
    test("solvedBy", () {
      final d = desc.Description.monochrome([1, 1]);
      expect(d.solvedBy(ListLine([1, 1, 0])), false);
      expect(d.solvedBy(ListLine([1, 0, 1])), true);
      expect(d.solvedBy(ListLine([0, 1, 0, 1])), true);
    });
  });
}
