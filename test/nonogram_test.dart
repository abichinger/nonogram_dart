import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/nonogram_dart.dart';
import 'package:nonogram_dart/src/description.dart' as desc;

void main() {
  group("Line", () {
    test("toDescription", () {
      final l1 = ListLine([1, 0, 1]);
      expect(l1.toDescription(), desc.Description.monochrome([1, 1]));

      final l2 = ListLine([1, null, 1, 1]);
      expect(l2.toDescription(), desc.Description.monochrome([1]));
      expect(
        l2.toDescription(returnIfNull: false),
        desc.Description.monochrome([1, 2]),
      );
    });
  });
}
