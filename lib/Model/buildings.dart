

import '../projet_dart_aeo.dart';


Map<String, int> buildingHealthENUM = {
  "T" : 1000,
  "H" : 200,
  "C" : 200,
  "F" : 100,
  "B" : 500,
  "S" : 500,
  "A" : 500,
  "K" : 800,

};
class Building{
  String uid;
  String name;
  int team;
  (int,int) position;
  double health;
  (int,int) surface;
  int nominalBuildingTime;
  int popAddition;
  int builders = 0;
  Map<String, int> cost;
  String spawns;

  Building(
      this.uid,
      this.team,
      this.name,
      this.position,
      this.health,
      this.surface,
      this.nominalBuildingTime,
      this.popAddition,
      this.spawns,
      {required this.cost}
      );

  List<(int,int)> getOccupiedTiles(){
    logger("Building size is ! $surface");
    List<(int,int)> finalPositions = [];
    int finalXPos = position.$1+surface.$1;
    int finalYPos = position.$2+surface.$2;
    for (int y=position.$2; y<finalYPos; y++){
      for (int x=position.$1; x<finalXPos; x++){
        logger("Pos are ${x},${y}");
        finalPositions.add((x,y));
      }
    }
    return finalPositions;
  }
  @override
  String toString() {
    return "${health ==  buildingHealthENUM[name]! ? colorMap[team] : colorMap[10]}$name${colorMap[9]}";
  }

  bool isInRange((int,int) position){
    logger("Position is weewee $position");
    return (position[0]-this.position[0]).abs() <= 1 && (position[1]-this.position[1]).abs() <= 1;
  }
}


class TownCenter extends Building {
  TownCenter(
      String uid,
      (int,int) position,
      int team,
      ) : super(
    uid,
    team,
    "T",
    position,
    0,
    (4, 4),
    60,
    5,
    "v",
    cost: {"w" : 350}
  );

}

class House extends Building {
  House(String uid,
      (int, int) position,
      int team,) : super(
      uid,
      team,
      "H",
      position,
      0,
      (2, 2),
      25,
      5,
      "",
      cost: {"w": 25}
  );
}

class Camp extends Building {
  Camp(String uid,
      (int, int) position,
      int team,) : super(
      uid,
      team,
      "C",
      position,
      0,
      (2, 2),
      25,
      0,
      "",
      cost: {"w": 25}
  );
}
class Barracks extends Building {
  Barracks(
      String uid,
      (int,int) position,
      int team,
      ) : super(
      uid,
      team,
      "B",
      position,
      0,
      (3, 3),
      50,
      0,
      "s",
      cost: {"w" : 175}
  );

}

class Farm extends Building {
  Farm(String uid,
      (int, int) position,
      int team,) : super(
      uid,
      team,
      "F",
      position,
      0,
      (2, 2),
      10,
      0,
      "",
      cost: {"w": 60}
  );
}

class Stable extends Building {
  Stable(String uid,
      (int, int) position,
      int team,) : super(
      uid,
      team,
      "S",
      position,
      0,
      (3, 3),
      50,
      0,
      "h",
      cost: {"w": 175}
  );
}

class ArcheryRange extends Building {
  ArcheryRange(String uid,
      (int, int) position,
      int team,) : super(
      uid,
      team,
      "A",
      position,
      0,
      (3, 3),
      50,
      0,
      "a",
      cost: {"w": 175}
  );
}

class Keep extends Building {
  Keep(String uid,
      (int, int) position,
      int team,) : super(
      uid,
      team,
      "K",
      position,
      0,
      (1, 1),
      80,
      0,
      "",
      cost: {"w": 35,"g":125}
  );
}



class BuildingFactory {
  static final Map<String, Function> buildingInitDict = {
    "T": (uid,position,team) => TownCenter(uid,position,team),
    "H" : (uid,position,team) => House(uid,position,team),
    "C" : (uid,position,team) => Camp(uid,position,team),
    "F" : (uid,position,team) => Farm(uid,position,team),
    "B" : (uid,position,team) => Barracks(uid,position,team),
    "S" : (uid,position,team) => Stable(uid,position,team),
    "A" : (uid,position,team) => Keep(uid,position,team),
  };

  static final Map<String, String> buildingSpawnDict = {
    "a" : "A",
    "h" : "S",
    "s" : "B",
    "v" : "T",
  };
  static final Map<String, (int,int)> buildingSizeDict = {
    "T" : (4,4),
    "A" : (3,3),
    "K" : (1,1),
    "B" : (3,3),
    "F" : (2,2),
    "C" : (2,2),
    "H" : (2,2),
    "S" : (3,3),
  };

  static (int,int)? getSize(String key){
    if (buildingSizeDict.containsKey(key)) {
      return buildingSizeDict[key]; // Call the constructor function
    }
    return null;
  }

  static Building? createBuilding(String key, uid,position,team) {
    if (buildingInitDict.containsKey(key)) {
      return buildingInitDict[key]!(uid,position,team); // Call the constructor function
    }
    return null;
  }
}


