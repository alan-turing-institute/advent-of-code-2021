import 'package:tuple/tuple.dart';
import 'dart:math';

int argMax<num>(List<int> list) {
  var maxArg = 0;
  int max = 0;

  var i = 0;

  for (final element in list) {
    if (element > max) {
      max = element;
      maxArg = i;
    }
    i++;
  }
  return maxArg;
}

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  @override
  String toString() {
    return 'Point($x, $y)';
  }
}

class Probe {
  final start = Point(0, 0);
  Point velocity;
  Point targetStart;
  Point targetEnd;

  Probe(this.velocity, this.targetStart, this.targetEnd);

  Tuple2<bool, List<Point>> simulate() {
    List<Point> allPositions = [];

    allPositions.add(start);

    while (true) {
      var lastPosition = allPositions[allPositions.length - 1];

      var newPosition =
          Point(lastPosition.x + velocity.x, lastPosition.y + velocity.y);

      allPositions.add(newPosition);

      if (velocity.x > 0) {
        velocity.x -= 1;
      } else {
        if (velocity.x < 0) {
          velocity.x += 1;
        }
      }
      velocity.y -= 1;

      // Hit target
      if ((targetStart.x <= newPosition.x) &
          (newPosition.x <= targetEnd.x) &
          (targetStart.y <= newPosition.y) &
          (newPosition.y <= targetEnd.y)) {
        return Tuple2(true, allPositions);
      }

      if (newPosition.y < targetStart.y) {
        return Tuple2(false, allPositions);
      }
    }
  }
}

void main(List<String> arguments) {
  final targetStart = Point(277, -92);
  final targetEnd = Point(318, -53);

  // final targetStart = Point(20, -10);
  // final targetEnd = Point(30, -5);

  List<Tuple2<bool, List<Point>>> allProbes = [];

  for (var y = min(targetStart.y, targetEnd.y);
      y < -min(targetStart.y, targetEnd.y);
      y++) {
    for (var x = 1; x <= targetEnd.x; x++) {
      allProbes.add(Probe(Point(x, y), targetStart, targetEnd).simulate());
    }
  }

  final allHitProbes = allProbes.where((probe) => probe.item1);

  final maximumYPosition = allHitProbes
      .map((probe) => probe.item2.map((point) => point.y).reduce(max));

  var part1 = maximumYPosition.toList().reduce(max);

  print("Part 1 = $part1");
  print("Part 2 = ${allHitProbes.toList().length}");
}
