import 'dart:math';
import 'package:projet_dart_aeo/projet_dart_aeo.dart';
import 'package:projet_dart_aeo/Model/resources.dart';
import 'tile.dart';
import 'World.dart';







(int,int) sumTuple((int,int) p1, (int,int) p2) {
  return (p1[0] + p2[0], p1[1] + p2[1]);
}

void cluster(World world, Resources resource, (int,int) key,
    [int repl = 50, int fade = 16]) {
  Resources? newResource;

  if (resource.name == "w") {
    newResource = Wood(key);
  } else if (resource.name == "g") {
    newResource = Gold(key);
  }

  if (newResource != null) {
    newResource.position = (key[0], key[1]);

    if (key[0] >= 0 && key[1] < world.width && key[1] >= 0 && key[1] < world.height) {
      world.tiles[key] = Tile(key)..contains = newResource;
      world.resources.putIfAbsent(key, () => newResource!);

      for (var i = -1; i <= 1; i++) {
        for (var j = -1; j <= 1; j++) {
          if (Random().nextInt(100) < repl) {
            var newKey = sumTuple(key, (i, j));
            if (newKey[0] >= 0 && newKey[0] < world.width && newKey[1] >= 0 && newKey[1] < world.height) {
              cluster(world, newResource, newKey, repl - fade);
            }
          }
        }
      }
    }
  }
}

World randomWorld(Map<String, dynamic> dict) {
  var newWorld = World(dict["X"], dict["Y"]);
  var mapType = dict["t"];
  var wealth = (newWorld.width * newWorld.height ~/ 4800);

  if (mapType == "g") {
    for (var i = 0; i < wealth + 2; i++) {
      var number = Random().nextInt(8) + 1;
      var x = Random().nextInt(newWorld.width ~/ number);
      var y = Random().nextInt(newWorld.height ~/ (9 - number));
      cluster(newWorld, Wood((x,y)), (x, y));
      cluster(newWorld, Wood((x,y)), (newWorld.width - x - 1, y));
      cluster(newWorld, Wood((x,y)), (newWorld.width - x - 1, newWorld.height - y - 1));
      cluster(newWorld, Wood((x,y)), (x, newWorld.height - y - 1));
    }
  }
  return newWorld;
}
