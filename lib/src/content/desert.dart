library hauberk.content.desert;

import 'dart:math' as math;

import 'package:piecemeal/piecemeal.dart';

import '../engine.dart';
import 'stage_builder.dart';
import 'tiles.dart';

class Desert extends StageBuilder {

  /// Number of iterations of the cell transformation rules to run on the grid.
  ///
  /// Less iterations create more spiky terrain, with a greater likelihood of
  /// unreachable spaces being present.
  int get generatorIterations => 4;

  /// Percentage of walls to keep on the initial map.
  ///
  /// When this is too low, the stage is covered by a featureless sandpit.
  int get initialWallPercent => 45;

  /// Threshold of adjacent cells to transform a wall tile into a floor tile.
  int get wallToFloorUpperThreshold => 2;

  /// Threshold of adjacent cells to transform a floor tile into a wall tile.
  int get floorToWallLowerThreshold => 5;

  Desert();

  void generate(Stage stage) {
    bindStage(stage);

    fill(Tiles.canyon);

    // Randomly place walls inside the inner grid.
    for (var y = 1; y < stage.height-1; y++) {
      for (var x = 1; x < stage.width-1; x++) {
        if (rng.range(100) > initialWallPercent) {
          setTile(new Vec(x, y), Tiles.sand);
        }
      }
    }

    // Carve out the desert spaces from the grid
    // - Wall cells with less than two adjacent walls become floors.
    // - Floor cells with more than five adjacent walls become walls.
    for (var i = 0; i < generatorIterations; i++) {
      for (var y = 1; y < stage.height-1; y++) {
        for (var x = 1; x < stage.width-1; x++) {
          var cell = new Vec(x, y);
          var adjacentWalls = countAdjacentWalls(cell);
          if (getTile(cell) == Tiles.canyon && adjacentWalls < wallToFloorUpperThreshold) {
            setTile(cell, Tiles.sand);
          } else if (getTile(cell) == Tiles.sand && adjacentWalls > floorToWallLowerThreshold) {
            setTile(cell, Tiles.canyon);
          }
        }
      }
    }

    // Remove walls with adjacent floor cells in each cardinal direction.
    for (var y = 1; y < stage.height-1; y++) {
      for (var x = 1; x < stage.width-1; x++) {
        var cell = new Vec(x, y);

        if (getTile(cell) == Tiles.sand) continue;

        // Check if this wall is blocking floor tiles on a North/South or East/West axis
        if ((getTile(cell.offset(0, -1)) == Tiles.sand && getTile(cell.offset(0, 1)) == Tiles.sand) ||
            (getTile(cell.offset(1, 0)) == Tiles.sand && getTile(cell.offset(-1, 0)) == Tiles.sand)) {
          setTile(cell, Tiles.sand);
        }
      }
    }

    erode(10000, floor: Tiles.sand, wall: Tiles.canyon);

    // Randomly vary the wall type.
    var walls = [Tiles.canyon, Tiles.mesa];
    for (var pos in stage.bounds) {
      if (getTile(pos) == Tiles.canyon) {
        setTile(pos, rng.item(walls));
      }
    }

  }

  // Count the number of adjacent tiles that are walls.
  int countAdjacentWalls(Vec pos) {
    var walls = 0;

    if (getTile(pos.offset(-1, -1)) == Tiles.canyon) {
      walls++;
    }

    if (getTile(pos.offset(0, -1)) == Tiles.canyon) {
      walls++;
    }

    if (getTile(pos.offset(1, -1)) == Tiles.canyon) {
      walls++;
    }

    if (getTile(pos.offset(1, 1)) == Tiles.canyon) {
      walls++;
    }

    if (getTile(pos.offset(0, -1)) == Tiles.canyon) {
      walls++;
    }

    if (getTile(pos.offset(-1, 1)) == Tiles.canyon) {
      walls++;
    }

    if (getTile(pos.offset(-1, 0)) == Tiles.canyon) {
      walls++;
    }

    return walls;
  }

}
