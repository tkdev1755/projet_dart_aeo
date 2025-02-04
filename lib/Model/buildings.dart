

import '../projet_dart_aeo.dart';

class Building{
  String uid;
  String name;
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
    return name;
  }

  bool isInRange((int,int) position){
    return (position[0]-this.position[0]).abs() <= 1 && (position[1]-this.position[1]).abs();
  }
}


class TownCenter extends Building {
  TownCenter(
      String uid,
      (int,int) position,
      ) : super(
    uid,
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

