

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
      );

  List<(int,int)> getOccupiedTiles(){
    logger("Building size is ! $surface");
    List<(int,int)> finalPositions = [];
    int finalXPos = position.$1+surface.$1;
    int finalYPos = position.$2+surface.$2;
    for (int y=position.$2; y<finalYPos; y++){
      for (int x=position.$1; x<finalXPos; x++){
        finalPositions.add((x,y));
      }
    }
    return finalPositions;
  }
  @override
  String toString() {
    return name;
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
    "v"
  );


}

