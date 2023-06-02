import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nonogram_dart/nonogram_dart.dart';
import 'package:nonogram_dart/src/description.dart' as desc;

import 'test_util.dart';

void main() {
  const b = Colors.black;
  const w = Colors.white;

  group("Line", () {
    test("toDescription", () {
      final l1 = ListLine([b, w, b]);
      expect(l1.toDescription(), desc.Description.monochrome([1, 1]));

      final l2 = ListLine([b, null, b, b]);
      expect(l2.toDescription(), desc.Description.monochrome([]));
      expect(
        l2.toDescription(returnIfNull: false),
        desc.Description.monochrome([1, 2]),
      );

      final l3 = ListLine([b, w, null, b]);
      expect(l3.toDescription(), desc.Description.monochrome([1]));
      expect(
        l3.toDescription(returnIfNull: false),
        desc.Description.monochrome([1, 1]),
      );

      final l4 = ListLine([null, null, null]);
      expect(l4.toDescription(), const desc.Description([]));
      expect(l4.toDescription(returnIfNull: false), const desc.Description([]));
    });
  });

  group("Grid", () {
    test("fromPng", () {
      final expected = [
        [b, w, w],
        [w, b, w],
        [w, w, b],
      ];

      final grid =
          Grid.fromPng(File('test/puzzles/stairs.png').readAsBytesSync());
      expectGrid(grid, expected);
    });

    test("toPng", () {
      final expected = [
        [b, w, w],
        [w, b, w],
        [w, w, b],
      ];

      final grid = Grid(expected);
      final grid2 = Grid.fromPng(grid.toPng());

      expectGrid(grid2, expected);
    });

    test("getHash", () {
      final target =
          Grid.fromPng(File('test/puzzles/target.png').readAsBytesSync());
      expect(
        target.getHash(),
        "dc2706bd1bcf74d70f7f99518fd620210e198f5dd604f728fa10a39588ef43c5",
      );

      final stairs =
          Grid.fromPng(File('test/puzzles/stairs.png').readAsBytesSync());
      expect(
        stairs.getHash(),
        "63f7b6eefc27e80fa15ee68da3230453e525591225efedc7faa9027ac3f5f420",
      );
    });
  });

  group("Nonogram", () {
    test("filled", () {
      final grid =
          Grid.fromPng(File('test/puzzles/stairs.png').readAsBytesSync());
      final nonogram = grid.toNonogram();
      expect(nonogram.filledPercentage, 3 / 9);
    });

    test("maxSegments", () {
      final grid =
          Grid.fromPng(File('test/puzzles/target.png').readAsBytesSync());
      final nonogram = grid.toNonogram();
      expect(nonogram.maxRowSegments, 3);
      expect(nonogram.maxColumnSegments, 5);
    });
  });
}
