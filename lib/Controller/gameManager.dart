



import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:projet_dart_aeo/Model/resources.dart';
import 'package:projet_dart_aeo/projet_dart_aeo.dart';

import '../Model/World.dart';
import '../Model/unit.dart';


Map<String, Type> unitInitDict = {
  "v" : Villager,
};



class GameManager{

  World world;
  DateTime tick;
  int gameSpeed = 1;
  Map<String, Map<String,dynamic>> moveDict = {};
  Map<String, Map<String,dynamic>> attackDict = {};
  Map<String, Map<String,dynamic>> buildDict = {};
  Map<String, Map<String, dynamic>> spawnDict = {};
  Map<String,Map<String,dynamic>> resourceDict = {};
  List<Unit> unitsToRemove = [];

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

  int removeDeadUnit(String uid){
    if (moveDict.containsKey(uid)){
      moveDict.remove(uid);
    }
    if (attackDict.containsKey(uid)){
      attackDict.remove(uid);
    }
    for (var key in buildDict.keys){
      if (buildDict[key]!["people"].contains(uid)){
        buildDict[key]!["people"].remove(uid);
        if (buildDict[key]!["people"].isEmpty()){
          buildDict.remove(key);
        }
      }
    }
    return 0;
  }
  int getTeamNumber(String uid){
    int pIndex = uid.indexOf("p");
    int eqIndex = uid.indexOf("q");
    String finalString = uid.substring(eqIndex+1,pIndex);
    logger("Final String is $finalString");
    return int.parse(finalString);
  }

  double getDelta(){
    Duration delta = DateTime.now().difference(tick);
    int igDelta = delta.inMicroseconds*gameSpeed;
    double igDeltaInSeconds = igDelta/(pow(10, 6));
    return igDeltaInSeconds;
  }

  int checkModifications(){
    checkUnitToMove();
    checkBuildingToBuild();
    checkUnitToSpawn();
    checkUnitToAttack();
    checkUnitToRemove();
    return 0;
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

  int checkUnitToAttack(){
    List<dynamic> elementToRemove = [];
    attackDict.forEach((k,v){
      if (v["finished"]){
        elementToRemove.add(k);
      }
      else{
        attackUnit(k);
      }
    }
    );
    for (var value in elementToRemove){
      attackDict.remove(value);
    }
    return 0;
  }

  int checkUnitToSpawn(){
    List<dynamic> elementToRemove = [];
    spawnDict.forEach((k,v){
      if (v["initialized"]){
        elementToRemove.add(k);
      }
      else{
        spawnUnit(k);
      }
    }
    );
    for (var value in elementToRemove){
      spawnDict.remove(value);
    }
    return 0;
  }

  int checkUnitToRemove(){
    for (var value in unitsToRemove){
      removeDeadUnit(value.uid);
    }
    unitsToRemove.clear();
    return 0;
  }

  int addUnitToMoveDict(Unit unit, (int,int) goal, {List<(int, int)>? optionalPath}){
    List<(int,int)> barriers = getMapBarriers();
    (int,int) distance = estimateDistance(unit.position, goal);
    List<(int,int)> path = optionalPath ?? AStar(rows: world.width, columns: world.height, start: unit.position, end: goal, barriers: barriers).findThePath().toList();
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

  int addUnitToSpawnDict(String type, int team){
    String nextUID = world.villages[team-1].getNextUID(type);
    (int,int) tcPosition = world.villages[team-1].community["T"].entries.first.value.position;
    spawnDict[nextUID] = {
      "newID" : nextUID,
      "unitTeam" : team,
      "unitType" : type,
      "spawnPosition" : (tcPosition[0]-1,tcPosition[1]-1),
      "timeElapsed": 0,
      "timeToTrain" : unitTrainTimeENUM[type],
      "initialized" : false,
      "fullyTrained" : false,
    };
    return 0;
  }

  int addResourceToCollectDict(Unit unit, Resources selectRes,Building nearDP, int quantity){
    List<(int,int)> nearDPPath = AStar(rows: world.width, columns: world.height, start: selectRes.position, end: nearDP.position, barriers: getMapBarriers()).findThePath().toList();
    resourceDict[unit.uid] = {
      "resPosition" : selectRes.position,
      "resType" : selectRes.name,
      "unitTeam" : unit.team,
      "unitType" : unit.name,
      "quantity" : quantity,
      "nearDP": nearDP,
      "nearDPPath" : nearDPPath,
      "droppingResources" : true,
      "collectedResoures" : false,
    };
    return 0;
  }

  int addUnitToAttackDict(List<Unit> attackers, dynamic target){
    (int,int) targetPosition = moveDict.containsKey(target.uid) && (target is Unit) ? moveDict[target.uid]!["goal"] : target.position;
    if (attackers[0].team == target.team){
      logger("Friendly fire not allowed");
      return -1;
    }
    else{
      for (var value in attackers){
        attackDict[value.uid] = {
          "attackerTeam" : value.team,
          "attackerType" : value.name,
          "targetID" : target.uid,
          "targetTeam" : target.team,
          "targetType" : target.name,
          "targetInRange" : false,
          "lastHitTime": 0,
          "targetPosition" : targetPosition,
          "movingTarget" : target is Unit,
          "finished" : false,
        };
      }
      return 0;
    }

  }

  int moveUnit(uid){
    double igDelta = getDelta();
    Map<String, dynamic> unitToMove = moveDict[uid]!;
    Unit unitInstance = getUnitInstance(unitToMove["unitTeam"], uid, unitToMove["unitType"]);
    if (moveDict[uid]!["timeElapsed"] >= moveDict[uid]!["timeToTile"]){
      logger("Unit arrived to the next tile");
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
      moveDict[uid]!["timeElapsed"] += igDelta;
    }
    return 0;
  }

  int attackUnit(uid){
    Duration delta = DateTime.now().difference(tick);
    int igDelta = delta.inMilliseconds*gameSpeed;
    double igDeltaInSeconds = igDelta/1000;
    Map<String, dynamic> attackingUnit = attackDict[uid]!;
    Unit attackerInstance = getUnitInstance(attackingUnit["attackerTeam"], uid, attackingUnit["attackerType"]);
    dynamic targetInstance = getUnitInstance(attackingUnit["targetTeam"], attackingUnit["targetID"], attackingUnit["targetType"]);
    (int,int) targetPosition = moveDict.containsKey(targetInstance.uid) && (targetInstance.uid.contains("p")) ? moveDict[attackingUnit["targetID"]]!["goal"] : attackingUnit["targetPosition"];
    (int,int) updateDistance = estimateDistance(targetPosition,  attackingUnit["targetPosition"]);
    (int,int) distanceToGoal = estimateDistance(targetPosition, attackerInstance.position);
    if (targetPosition != attackingUnit["targetPosition"]
        && (updateDistance[0] > attackerInstance.range && updateDistance[1] > attackerInstance.range)){
      logger("Target position seems to have changed beyond attacker range");
      addUnitToMoveDict(attackerInstance, targetPosition);
    }
    if (distanceToGoal[0] <= attackerInstance.range && distanceToGoal[1] <= attackerInstance.range){
      logger("Now in range");
      attackingUnit["targetInRange"] = true;
      if (attackingUnit["lastHitTime"] < 1){
        attackingUnit["lastHitTime"] += igDeltaInSeconds;
      }
      else{
        world.villages[targetInstance.team-1].community[targetInstance.name][targetInstance.uid].health -= attackerInstance.damage;
        if( world.villages[targetInstance.team-1].community[targetInstance.name][targetInstance.uid].health < 0){
          logger("Unit is dead ! ");
          world.villages[targetInstance.team-1].markAsDead(targetInstance);
          if(targetInstance is Unit){
            unitsToRemove.add(targetInstance);
          }
          attackingUnit["finished"] = true;
        }
      }
    }
    else{
      attackingUnit["targetInRange"] = true;
      logger("not in range");

    }

    return 0;
  }

  int spawnUnit(String uid){
    Duration delta = DateTime.now().difference(tick);
    int igDelta = delta.inMilliseconds*gameSpeed;
    double igDeltaInSeconds = igDelta/1000;
    Map<String, dynamic> unitToSpawn = spawnDict[uid]!;
    if (unitToSpawn["fullyTrained"]) {
      logger("Unit fully trained, starting healthFill");
      logger("Initializing unit");
      dynamic newUnit = UnitFactory.createUnit(
          unitToSpawn["unitType"], unitToSpawn["newID"],
          unitToSpawn["spawnPosition"], unitToSpawn["unitTeam"]);
      if (newUnit != null) {
        world.villages[unitToSpawn["unitTeam"]! - 1].addUnit(newUnit);
        unitToSpawn["initialized"] = true;
      }
    }
    else{
      if (unitToSpawn["timeElapsed"] > unitToSpawn["timeToTrain"]){
        logger("Time to train has passed, now initializing unit");
        unitToSpawn["fullyTrained"] = true;
      }
      else{
        unitToSpawn["timeElapsed"] += igDeltaInSeconds;
      }
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
      double timeToBuild = 3 * bldToBuild["timeToBuild"] / (
          (buildingInstance.builders) + 2);
      if (bldToBuild["timeElapsed"]> timeToBuild){
        logger("GameManager | buildBuilding ---Building finished !");
        bldToBuild["built"] = true;
        buildingInstance.health = buildingHealthENUM[buildingInstance.name]!.toDouble();
      }
      else{
        bldToBuild["timeElapsed"] += igDeltaInSeconds;
        buildingInstance.health += igDeltaInSeconds * buildingHealthENUM[buildingInstance.name]! / timeToBuild;
        logger("GameManager | buildBuilding --- Building building");
      }
    }
    else{
      List<Unit> buildersInstances = [];
      for (var value in bldToBuild["people"]){
         buildersInstances.add(getUnitInstance(bldToBuild["buildingTeam"], value, "v"));
      }
      logger("builderINSTANCE are $buildersInstances ");
      int presentBuilders = buildersInstances.where((e) => buildingInstance.isInRange(e.position)).length;
      buildingInstance.builders = presentBuilders;
      if (presentBuilders == bldToBuild["people"].length){
        logger("GameManager | buildBuilding --- All people on board, ready to build the building");
        bldToBuild["readyToBuild"] = true;
      }
      else{
        logger("GameManager | buildBuilding --- Waiting for people to come");
      }
    }
    return 0;
  }

  int collectResources(String id){
    //double igDelta = getDelta();
    Map<String,dynamic> resToCollect = resourceDict[id]!;
    Unit unitInstance = getUnitInstance(resToCollect["unitTeam"], id, resToCollect["unitType"]);
    Resources? resInstance = world.resources[resToCollect["resPosition"]];
    Building dpInstance = resToCollect["nearDP"];
    if (resInstance == null) {
      logger("Ressources doesn't exist");
      return -1;
    }
    else {
      (int,int) resDistance = estimateDistance(unitInstance.position, resInstance.position);
      if (resDistance[0] <= 1 && resDistance[1]  <= 1){
        logger("Unit is near resource, start collecting");
      }
      else if (unitInstance.isFull()){
        logger("Unit is full, going back to DP");
        resToCollect["droppingResources"] = true;
        addUnitToMoveDict(unitInstance, dpInstance.position, optionalPath: resToCollect["nearDPPath"]);
      }
      else{
        logger("waiting for unit to come to resource");
      }
    }
    return 0;
  }

}