

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

