import 'package:nonogram_dart/src/description.dart';
import 'package:nonogram_dart/src/nonogram.dart';

class Step {
  final int i;
  final int color;
  final bool branch;

  const Step(
    this.i,
    this.color, {
    this.branch = false,
  });
}

abstract class LineSolver {
  List<Step> getSteps();
}

class PermutationSolver implements LineSolver {
  final Line line;
  final Description description;

  const PermutationSolver(this.line, this.description);

  @override
  List<Step> getSteps() {
    var permutations = description.iterPossible(line);
    if (permutations.isEmpty) {
      return [];
    }

    final fixed = line.fixed;
    var merged = permutations.first;
    for (var permutation in permutations) {
      merged.merge(permutation);
      if (merged.fixed.length <= fixed.length) {
        return [];
      }
    }

    Set<int> newBlocks = merged.fixed.difference(fixed);
    return newBlocks.map((i) => Step(i, merged.get(i) as int)).toList();
  }
}

class LineDescription {
  final Description description;
  final List<int> spaces;

  const LineDescription(this.description, this.spaces);

  factory LineDescription.from(Description description) {
    final spaces =
        List.generate(description.length, (index) => index == 0 ? 0 : 1);
    return LineDescription(description, spaces);
  }

  factory LineDescription.empty() {
    return const LineDescription(Description([]), []);
  }

  List<Stroke> get strokes => description.strokes;

  int get _sumSpaces => spaces.fold(0, (acc, space) => acc + space);

  int get length => description.sumStrokes + _sumSpaces;

  LineDescription copy() {
    return LineDescription.from(description);
  }

  List<int?> toLine(int lineLength) {
    List<int?> line = List.filled(lineLength, NgColors.spaceColor);
    var offset = 0;
    for (var i = 0; i < spaces.length; i++) {
      offset += spaces[i];
      final stroke = strokes[i];
      for (var j = 0; j < stroke.length; j++) {
        line[offset] = stroke.color;
        offset += 1;
      }
    }
    return line;
  }
}

class DescriptionIterator extends Iterable<Line> with Iterator<Line> {
  final LineDescription lineDescription;
  late final int _lineLength;
  late int _length;

  DescriptionIterator(this.lineDescription, int lineLength) {
    _length = lineDescription.length;
    _lineLength = lineLength + 1;
  }

  @override
  get current => ListLine(lineDescription.toLine(_lineLength).sublist(1));

  @override
  Iterator<Line> get iterator =>
      DescriptionIterator(lineDescription.copy(), _lineLength - 1);

  List<int> get spaces => lineDescription.spaces;

  @override
  bool moveNext() {
    final lengthLeft = _lineLength - _length;
    if (lengthLeft <= 0) {
      for (var i = 0; i < spaces.length - 1; i++) {
        if (spaces[i] > 1) {
          _length = _length - spaces[i] + 2;
          spaces[i] = 1;
          spaces[i + 1] += 1;
          return true;
        }
      }
      return false;
    } else {
      _length += 1;
      spaces[0] += 1;
    }
    return true;
  }
}

class PossibleLineIterator extends Iterable<Line> with Iterator<Line> {
  final Line line;
  final DescriptionIterator _descIter;
  late final Set<int> _fixed;

  PossibleLineIterator(this.line, this._descIter) {
    _fixed = line.fixed;
  }

  @override
  Line get current => _descIter.current;

  @override
  Iterator<Line> get iterator =>
      PossibleLineIterator(line, _descIter.iterator as DescriptionIterator);

  @override
  bool moveNext() {
    while (_descIter.moveNext()) {
      var current = _descIter.current;
      bool isPossible = true;
      for (var i in _fixed) {
        if (line.get(i) != current.get(i)) {
          isPossible = false;
          break;
        }
      }
      if (isPossible) {
        return true;
      }
    }
    return false;
  }
}

extension DescriptionIteratorExtension on Description {
  DescriptionIterator iter(int lineLength) {
    return DescriptionIterator(LineDescription.from(this), lineLength);
  }

  PossibleLineIterator iterPossible(Line line) {
    return PossibleLineIterator(line, iter(line.length));
  }
}
