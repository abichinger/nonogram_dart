import 'package:nonogram_dart/src/description.dart';
import 'package:nonogram_dart/src/nonogram.dart';
import 'package:nonogram_dart/src/solver/solver.dart';

class Position {
  final int row;
  final int column;

  const Position(this.row, this.column);
}

class Step {
  final Position pos;
  final int color;
  final bool branch;
  final int? descriptionIndex;
  final SolverFocus? focus;

  const Step(
    this.pos,
    this.color, {
    this.branch = false,
    this.descriptionIndex,
    this.focus,
  });

  factory Step.line(int i, int color, {bool branch = false}) {
    return Step(Position(0, i), color, branch: branch);
  }

  Step copyWith({
    Position? pos,
    int? color,
    bool? branch,
    int? descriptionIndex,
    SolverFocus? focus,
  }) {
    return Step(
      pos ?? this.pos,
      color ?? this.color,
      branch: branch ?? this.branch,
      descriptionIndex: descriptionIndex ?? this.descriptionIndex,
      focus: focus ?? this.focus,
    );
  }

  int get i => pos.column;
  int get row => pos.row;
  int get column => pos.column;
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
    return newBlocks.map((i) => Step.line(i, merged.get(i) as int)).toList();
  }
}

class LineDescription {
  final Description description;
  final List<int> spaces;

  const LineDescription(this.description, this.spaces);

  factory LineDescription.from(Description description) {
    final spaces = List.generate(
      description.length,
      (i) => description.minSpaceAt(i),
    );
    return LineDescription(description, spaces);
  }

  factory LineDescription.empty() {
    return const LineDescription(Description([]), []);
  }

  List<Stroke> get strokes => description.strokes;

  int get _sumSpaces => spaces.fold(0, (acc, space) => acc + space);

  int get length => description.sumStrokes + _sumSpaces;

  bool get isEmpty => description.isEmpty;

  LineDescription copy() {
    return LineDescription.from(description);
  }

  List<int?> toLine(int lineLength) {
    List<int?> line = List.filled(lineLength, Colors.white);
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
  bool _done = false;

  DescriptionIterator(this.lineDescription, int lineLength) {
    _length = lineDescription.length - 1;
    _lineLength = lineLength;

    // set to -1 for first iteration
    if (!lineDescription.isEmpty) {
      lineDescription.spaces[0] -= 1;
    }
  }

  @override
  get current => ListLine(lineDescription.toLine(_lineLength));

  @override
  Iterator<Line> get iterator =>
      DescriptionIterator(lineDescription.copy(), _lineLength);

  List<int> get spaces => lineDescription.spaces;

  @override
  bool moveNext() {
    if (_done) {
      return false;
    }

    if (lineDescription.isEmpty) {
      _done = true;
      return true;
    }

    final lengthLeft = _lineLength - _length;
    if (lengthLeft <= 0) {
      for (var i = 0; i < spaces.length - 1; i++) {
        final minSpaceAt = lineDescription.description.minSpaceAt(i);
        if (spaces[i] > minSpaceAt) {
          _length = _length - spaces[i] + minSpaceAt + 1;
          spaces[i] = minSpaceAt;
          spaces[i + 1] += 1;
          return true;
        }
      }
      _done = true;
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
