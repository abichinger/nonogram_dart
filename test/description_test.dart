import 'package:test/test.dart';
import 'package:nonogram_dart/nonogram_dart.dart';
import 'package:nonogram_dart/src/description.dart' as desc;

void main() {
  const b = Colors.black;
  const w = Colors.white;
  group("Description", () {
    test("solvedBy", () {
      final d = desc.Description.monochrome([1, 1]);
      expect(d.solvedBy(ListLine([b, b, w])), false);
      expect(d.solvedBy(ListLine([b, w, b])), true);
      expect(d.solvedBy(ListLine([w, b, w, b])), true);
    });

    test("json", () {
      final d = desc.Description.monochrome([1, 2]);

      expect(d, desc.Description.fromJson(d.toJson()));
    });
  });
}
