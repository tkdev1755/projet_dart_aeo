import 'dart:math';
import 'package:projet_dart_aeo/projet_dart_aeo.dart';
import 'package:projet_dart_aeo/Model/resources.dart';
import 'Village.dart';
import 'buildings.dart';
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
      world.resources.putIfAbsent(newResource.name, ()=>{});
      world.resources[newResource.name]!.putIfAbsent(key, () => newResource!);

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

/*void placeBuildings(World world, List<Building> buildings) {
  var rng = Random();
  List<(int, int)> townCenterPositions = [];
  int maxAttempts = 1000;

  for (var building in buildings) {
    int attempts = 0;
    bool placed = false;

    while (attempts < maxAttempts && !placed) {
      int x = rng.nextInt(world.width);
      int y = rng.nextInt(world.height);
      var key = (x, y);

      if (isPositionValid(world, x, y)) {
        if (building.type == "TownCenter") {
          bool tooClose = townCenterPositions.any((pos) =>
          (pos.$1 - x).abs() + (pos.$2 - y).abs() < world.width ~/ world.villages.length);
          if (tooClose) {
            attempts++;
            continue;
          }
          townCenterPositions.add(key);
        }

        world.tilesDico[key] = Tile()..contains = building;
        placed = true;
      }
      attempts++;
    }
  }
}*/



void placeTcs(Map<String, dynamic> dict, World world) {
  final random = Random();
  int x = random.nextInt(world.width ~/ 3 - 24) + 12;
  int y = random.nextInt(world.height ~/ 3 - 24) + 12;

  // Clear space
  for (int j = y - 8; j < y + 20; j++) {
    for (int i = x - 8; i < x + 20; i++) {
      if (world.tiles.containsKey((i,j))){
        String type = world.tiles[(i,j)]!.contains.name;
        if (world.resources[type]!.containsKey((i,j)) && world.tiles[(i,j)]!.contains is Resources){
          world.resources[type]!.remove((i,j));
        }
      }
      world.tiles.remove((world.width - i, world.height - j));
      if (world.tiles.containsKey((world.width - i, world.height - j))){
        String type = world.tiles[(world.width - i, world.height - j)]!.contains.name;
        if (world.resources[type]!.containsKey((world.width - i, world.height - j)) && world.tiles[(world.width - i, world.height - j)]!.contains is Resources){
          world.resources[type]!.remove((world.width - i, world.height - j));
        }
      }
      world.tiles.remove((world.width - i, world.height - j));

      if (dict["n"] >= 3) {
        if (world.tiles.containsKey((i, world.height - j))){
          String type = world.tiles[(i, world.height - j)]!.contains.name;
          if (world.resources[type]!.containsKey((i, world.height - j)) && world.tiles[(i, world.height - j)]!.contains is Resources){
            world.resources[type]!.remove((i, world.height - j));
          }
        }
        world.tiles.remove((i, world.height - j));
      }
      if (dict["n"] >= 4) {
        if (world.tiles.containsKey((world.width - i, j))){
          String type = world.tiles[(world.width - i, j)]!.contains.name;
          if (world.resources[type]!.containsKey((world.width - i, j)) && world.tiles[(world.width - i, j)]!.contains is Resources){
            world.resources[type]!.remove((world.width - i, j));
          }
        }
        world.tiles.remove((world.width - i, j));
      }
      if (dict["n"] >= 5) {
        if (world.tiles.containsKey((world.width ~/ 2 - i, j))){
          String type = world.tiles[(world.width ~/ 2 - i, j)]!.contains.name;
          if (world.resources[type]!.containsKey((world.width ~/ 2 - i, j)) && world.tiles[(world.width ~/ 2 - i, j)]!.contains is Resources){
            world.resources[type]!.remove((world.width ~/ 2 - i, j));
          }
        }
        world.tiles.remove((world.width ~/ 2 - i, j));
      }
      if (dict["n"] >= 6) {
        if (world.tiles.containsKey((world.width ~/ 2 - i, world.height - j))){
          String type = world.tiles[(world.width ~/ 2 - i, world.height - j)]!.contains.name;
          if (world.resources[type]!.containsKey((world.width ~/ 2 - i, world.height - j)) && world.tiles[(world.width ~/ 2 - i, world.height - j)]!.contains is Resources){
            world.resources[type]!.remove((world.width ~/ 2 - i, world.height - j));
          }
        }
        world.tiles.remove((world.width ~/ 2 - i, world.height - j));
      }
      if (dict["n"] >= 7) {
        if (world.tiles.containsKey((i, world.height ~/ 2 - j))){
          String type = world.tiles[(i, world.height ~/ 2 - j)]!.contains.name;
          if (world.resources[type]!.containsKey((i, world.height ~/ 2 - j)) && world.tiles[(i, world.height ~/ 2 - j)]!.contains is Resources){
            world.resources[type]!.remove((i, world.height ~/ 2 - j));
          }
        }
        world.tiles.remove((i, world.height ~/ 2 - j));
      }
      if (dict["n"] >= 8) {
        if (world.tiles.containsKey((world.width - i, world.height ~/ 2 - j))){
          String type = world.tiles[(world.width - i, world.height ~/ 2 - j)]!.contains.name;
          if (world.resources[type]!.containsKey((world.width - i, world.height ~/ 2 - j)) && world.tiles[(world.width - i, world.height ~/ 2 - j)]!.contains is Resources){
            world.resources[type]!.remove((world.width - i, world.height ~/ 2 - j));
          }
        }
        world.tiles.remove((world.width - i, world.height ~/ 2 - j));
      }
    }
  }

  // Place Town Centers
  logger("number of villages is ${dict["n"]}");
  for (int i = 0; i < dict["n"]; i++) {
    Village village = world.getVillage(i+1);
    String uid = village.getNextUID("b");
    TownCenter tc = TownCenter(uid, (0,0), village.name);
    tc.health = buildingHealthENUM["T"]!.toDouble();
    (int,int) pos;
    switch (i) {
      case 0:
        pos = (x + 4, y + 4);
        break;
      case 1:
        pos = (world.width - x - 6, world.height - y - 6);
        break;
      case 2:
        pos = (x + 4, world.height - y - 6);
        break;
      case 3:
        pos = (world.width - x - 6, y + 4);
        break;
      case 4:
        pos = (world.width ~/ 2, y + 4);
        break;
      case 5:
        pos = (world.width ~/ 2, world.height - y - 6);
        break;
      case 6:
        pos = (x + 4, world.height ~/ 2);
        break;
      case 7:
        pos = (world.width - x - 6, world.height ~/ 2);
        break;
      default:
        pos = (x, y);
    }
    logger("Final TC position is ${pos}");

    tc.position = pos;
    village.addBuilding(tc, overrideCost: true);
  }
}


