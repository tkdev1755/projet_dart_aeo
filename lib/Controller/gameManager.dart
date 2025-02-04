



import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:projet_dart_aeo/projet_dart_aeo.dart';

import '../Model/World.dart';
import '../Model/unit.dart';




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

class GameManager{

  World world;
  DateTime tick;
  int gameSpeed = 1;
  Map<String, Map<String,dynamic>> moveDict = {};
  Map<String, Map<String,dynamic>> attackDict = {};
  Map<String, Map<String,dynamic>> buildDict = {};

  GameManager(
      this.world,
      this.tick,
      );
  List<(int,int)> getMapBarriers(){
    List<(int,int)> barrierList = [];
    for (var value in world.tiles.entries){
      if (value.value.contains != null){
        barrierList.add(value.key);
      }
    }
    return barrierList;
  }


  (int, int) estimateDistance((int,int) t1,(int,int) t2){
    return ((t2[0]-t1[0]).abs(), (t2[1]-t1[1]).abs());
  }

  Unit getUnitInstance(int team,String uid,String type){
    return world.villages[team-1].community[type][uid];
  }

  Building getBuildingInstance(int team, String uid, String type){
    return world.villages[team-1].community[type][uid];
  }

  int getTeamNumber(String uid){
    int pIndex = uid.indexOf("p");
    int eqIndex = uid.indexOf("q");
    String finalString = uid.substring(eqIndex+1,pIndex);
    logger("Final String is $finalString");
    return int.parse(finalString);
  }

  int checkUnitToMove(){
    List<dynamic> elementToRemove = [];
    moveDict.forEach((k,v){
      if (v["arrived"]){
        elementToRemove.add(k);
      }
      else{
        moveUnit(k);
      }
    }
    );
    for (var value in elementToRemove){
      moveDict.remove(value);
    }
    return 0;
  }

  int checkBuildingToBuild(){
    List<dynamic> elementToRemove = [];
    buildDict.forEach((k,v){
      if (v["built"]){
        elementToRemove.add(k);
      }
      else{
        buildBuilding(k);
      }
    }
    );
    for (var value in elementToRemove){
      buildDict.remove(value);
    }
    return 0;
  }

  int addUnitToMoveDict(Unit unit, (int,int) goal){
    List<(int,int)> barriers = getMapBarriers();
    (int,int) distance = estimateDistance(unit.position, goal);
    List<(int,int)> path = AStar(rows: world.width, columns: world.height, start: unit.position, end: goal, barriers: barriers).findThePath().toList();
    if (path.isEmpty && distance[0] >= 1 && distance[1] >= 1){
      logger("Crash while computing path");
      return -1;
    }
    logger(" path is {$path}");
    moveDict[unit.uid] = {
      "unitID" : unit.uid,
      "unitTeam" : getTeamNumber(unit.uid),
      "unitType" : unit.name,
      "unitPos" : unit.position,
      "timeElapsed": 0,
      "timeToTile" : 1/unit.speed,
      "nextTile": path[1],
      "goal" : goal,
      "arrived" : false,
      "path" : path,
    };
    return 0;
  }

  int addBuildingToBuildDict(Building building, peopleList){
    buildDict[building.uid] = {
      "buildingID" : building.uid,
      "buildingTeam" : getTeamNumber(peopleList[0]),
      "buildingType" : building.name,
      "buildingPos" : building.position,
      "timeElapsed": 0,
      "timeToBuild" : building.nominalBuildingTime,
      "readyToBuild" : false,
      "built" : false,
      "people" : peopleList,
    };
    return 0;
  }

  int moveUnit(uid){
    Duration delta = DateTime.now().difference(tick);
    logger(" delta iiiis ? $delta");
    int igDelta = delta.inMicroseconds*gameSpeed;
    double igDeltaInSeconds = igDelta/(pow(10, 6));
    Map<String, dynamic> unitToMove = moveDict[uid]!;
    Unit unitInstance = getUnitInstance(unitToMove["unitTeam"], uid, unitToMove["unitType"]);
    if (moveDict[uid]!["timeElapsed"] >= moveDict[uid]!["timeToTile"]){
      logger("Unit arrived to its destination");
      moveDict[uid]!["timeElapsed"] = 0;

      (int,int) oldPos = moveDict[uid]!["path"][0];
      (moveDict[uid]!["path"] as List<(int,int)>).removeAt(0);
      if (moveDict[uid]!["nextTile"] == moveDict[uid]!["goal"]){
        logger("Next position is the final one");
        moveDict[uid]!["arrived"] = true;
        unitInstance.position = moveDict[uid]!["path"][0];
        world.updateUnitPosition(oldPos, unitInstance);
      }
      else{
        unitInstance.position = moveDict[uid]!["path"][0];
        world.updateUnitPosition(oldPos, unitInstance);
        moveDict[uid]!["nextTile"] = moveDict[uid]!["path"][1];
      }
    }
    else{
      logger("Before ---TimeElapsed is ${moveDict[uid]!["timeElapsed"]}");
      logger("igDelta is $igDelta");
      moveDict[uid]!["timeElapsed"] += igDeltaInSeconds;
      logger("TimeElapsed is ${moveDict[uid]!["timeElapsed"]}");
    }
    return 0;
  }

  int buildBuilding(String uid){
    Duration delta = DateTime.now().difference(tick);
    int igDelta = delta.inMilliseconds*gameSpeed;
    double igDeltaInSeconds = igDelta/1000;
    Map<String, dynamic> bldToBuild = buildDict[uid]!;
    Building buildingInstance = getBuildingInstance(bldToBuild["buildingTeam"], uid, bldToBuild["buildingType"]);
    if (bldToBuild["readyToBuild"]){
      double timeToBuild = 3 * bldToBuild["nominalBuildTime"] / (
          (buildingInstance.builders) + 2);
      if (bldToBuild["timeElapsed"]> timeToBuild){
        bldToBuild["built"] = true;
        buildingInstance.health = buildingHealthENUM[buildingInstance.name]!.toDouble();
      }
      else{
        bldToBuild["timeElapsed"] += igDeltaInSeconds;
        buildingInstance.health += igDeltaInSeconds * buildingHealthENUM[buildingInstance.name]! / timeToBuild;
        logger("Building building");
      }
    }
    else{
      List<Unit> buildersInstances = [];
      for (var value in bldToBuild["people"]){
        getUnitInstance(bldToBuild["buildingTeam"], value, "v");
      }
      int presentBuilders = buildersInstances.where((e) => buildingInstance.isInRange(e.position)).length;
      buildingInstance.builders = presentBuilders;
    }
    return 0;
  }

}