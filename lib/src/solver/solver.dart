import 'dart:math';

import 'package:nonogram_dart/nonogram_dart.dart';
import 'package:nonogram_dart/src/description.dart';
import 'package:nonogram_dart/src/nonogram.dart';
import 'package:nonogram_dart/src/solver/line_solver.dart';

abstract class Solver extends Iterable<Solver> {
  final Nonogram nonogram;
  final Grid grid;
  late List<Step> steps;

  Solver(
    this.nonogram,
    this.grid, {
    List<Step>? steps,
  }) {
    this.steps = steps ?? [];
  }

  List<Step> solve();
}

class LogicalSolver extends Solver {
  LogicalSolver(super.nonogram, super.grid, {super.steps});

  factory LogicalSolver.empty(Nonogram nonogram) {
    return LogicalSolver(
        nonogram,
        Grid.empty(
          width: nonogram.width,
          height: nonogram.height,
        ));
  }

  @override
  List<Step> solve() {
    while (true) {
      var stepsStart = steps.length;
      _sweep(grid.height, (i) => grid.getRow(i), (i) => nonogram.rows[i]);
      _sweep(grid.width, (i) => grid.getColumn(i), (i) => nonogram.columns[i]);

      // stop if solver is stalling
      if (stepsStart == steps.length) {
        break;
      }
    }
    return steps;
  }

  void _sweep(
    int n,
    Line Function(int i) getLine,
    Description Function(int i) getDescription,
  ) {
    for (var i = 0; i < n; i++) {
      final line = getLine(i);
      if (line.filledOut) {
        continue;
      }
      final lineSolver = PermutationSolver(line, getDescription(i));
      for (var step in lineSolver.getSteps()) {
        line.set(step.i, step.color);
        steps.add(step);
      }
    }
  }

  @override
  Iterator<Solver> get iterator {
    solve();
    return [this].iterator;
  }
}

class GuessingSolver extends Solver {
  GuessingSolver(super.nonogram, super.grid, {super.steps});

  factory GuessingSolver.empty(Nonogram nonogram) {
    return GuessingSolver(
        nonogram,
        Grid.empty(
          width: nonogram.width,
          height: nonogram.height,
        ));
  }

  @override
  Iterator<Solver> get iterator =>
      GuessingSolverIterator(LogicalSolver(nonogram, grid, steps: steps));

  @override
  List<Step> solve() {
    var iter = iterator..moveNext();
    var solver = iter.current;
    steps = solver.steps;
    return steps;
  }
}

class GuessingSolverIterator with Iterator<Solver> {
  late final List<LogicalSolver> _solvers = [];
  late Solver _solver;

  GuessingSolverIterator(LogicalSolver solver) {
    _solvers.add(solver);
  }

  @override
  Solver get current => _solver;

  @override
  bool moveNext() {
    if (_solvers.isEmpty) {
      return false;
    }

    while (_solvers.isNotEmpty) {
      _solver = _solvers.removeLast();
      final nonogram = _solver.nonogram;
      final grid = _solver.grid;

      final lSolver = LogicalSolver(nonogram, grid, steps: _solver.steps);
      lSolver.solve();

      if (nonogram.solvedBy(grid)) {
        return true;
      }

      if (grid.filledOut) {
        continue;
      }

      // start guessing
      Point<int> cell = const Point(-1, -1);
      for (var i = 0; i < grid.height; i++) {
        for (var j = 0; j < grid.width; j++) {
          if (grid.get(i, j) != null) {
            continue;
          }
          //TODO: support colored cells
          cell = Point(j, i);
        }
      }

      for (var color in [0, 1]) {
        var gridCopy = grid.copy();
        gridCopy.set(cell.y, cell.x, color);
        _solvers.add(LogicalSolver(nonogram, gridCopy,
            steps: [..._solver.steps, Step(-1, color, branch: true)]));
      }
    }

    return false;
  }
}
