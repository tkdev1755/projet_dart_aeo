



import 'package:projet_dart_aeo/Controller/gameManager.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:projet_dart_aeo/Model/resources.dart';
import 'package:projet_dart_aeo/Model/unit.dart';
import 'package:projet_dart_aeo/projet_dart_aeo.dart';

import 'Village.dart';
import 'World.dart';

enum PlayStyle {
  Aggressive,
  Passive,
  Defensive,
}

const Map<PlayStyle, List<List<int>>> playStyleMatrix = {
  PlayStyle.Aggressive: [
    [2, 2, 0],
    [6, 10, 4],
    [3, 4, 8]
  ],
  PlayStyle.Passive: [
    [6, 20, 0],
    [2, 2, 0],
    [1, 12, 2]
  ],
  PlayStyle.Defensive: [
    [9, 1, 9],
    [2, 8, 2],
    [1, 4, 0]
  ]
};

Map<String, Playstyle> playStyleENUM = {
  "Aggressive" : Playstyle(5, playStyleMatrix[PlayStyle.Aggressive]!),
  "Passive" : Playstyle(2, playStyleMatrix[PlayStyle.Passive]!),
  "Defensive" : Playstyle(1,playStyleMatrix[PlayStyle.Defensive]!)
};
enum BuildingType {
  T, A, B, C, F, H, K, S
}

const Map<String, String> buildingENUM = {
  "T": "T",
  "A": "A",
  "B": "B",
  "C": "C",
  "F": "F",
  "H": "H",
  "K": "K",
  "S": "S"
};


enum UnitType {
  a, h, v, s
}


const Map<String, Map<String, int>> buildingCostENUM = {
  "T": {"w": 350},
  "A": {"w": 175},
  "B": {"w": 175},
  "C": {"w": 100},
  "F": {"w": 60},
  "H": {"w": 25},
  "K": {"w": 35, "g": 125},
  "S": {"w": 175}
};


const Map<String, String> resourceTypeENUM = {
  "w" : "Wood",
  "g": "Gold",
  "f": "Food"
};

const Map<UnitType, int> unitTimeENUM = {
  UnitType.a: 35,
  UnitType.h: 30,
  UnitType.s: 20,
  UnitType.v: 25
};




const Map<String, List<String>> buildingTypeENUM = {
  "Military": ["B", "S", "A"],
  "Village": ["H", "T"],
  "Farming": ["F", "C"],
  "DropPoints": ["T", "C"]
};

const Map<String, List<String>> unitTypeENUM = {
  "Military": ["a", "s", "h"],
  "Village": ["v"],
  "Farming": ["v"]
};


class Playstyle{

    List<List<int>> playStyleMatrix;
    int minworkers;

    Playstyle(
        this.minworkers,
        this.playStyleMatrix,
        );

    void setPlayStyleMatrix(List<List<int>> matrix){
      playStyleMatrix = matrix;
    }

    List<List<int>> getPlayStyleMatrix(){
      return playStyleMatrix;
    }
}


class AIPlayer{

  World world;
  Village village;
  Playstyle playstyle;
  int level;
  GameManager gameManager;
  bool debug = false;
  Map<String,List<String>> freeUnits = {};
  List<Map<String, dynamic>> eventQueue = [];
  List<Map<String, dynamic>> pastEvent = [];
  List<Map<String, dynamic>> currentEvent = [];
  List<TownCenter> tcs = [];
  int spawningUnit = 0;
  (int,int) topVillageBorder = (0,0);
  AIPlayer(
      this.world,
      this.village,
      this.playstyle,
      this.level,
      this.gameManager,

      ){
    freeUnits = {
      "a" : village.community["a"]?.keys.toList() ?? [],
      "h" : village.community["h"]?.keys.toList() ?? [],
      "v" : village.community["v"]?.keys.toList() ?? [],
      "s" : village.community["s"]?.keys.toList() ?? []
    };
    List<TownCenter> tcList = (village.community["T"]?.values.toList() ?? []).cast();
    tcs = tcList;
    if (tcs.isNotEmpty){
      topVillageBorder = (tcs[0].position[0]-1,tcs[0].position[1]-1);
    }
  }


  void playTurn(){
    logger("----- AIPlayer n°${village.name} STARTED PLAYING ----");
    checkForDeadUnits();
    int workingPpl = village.getUnitNumber() - getFreePplCount();
    logger("AIPlayer | playTurn--- freeUnits are ${getFreePplCount()} ${freeUnits} and workingUnits are ${workingPpl}, village pop is ${village.getUnitNumber()}");
    if (workingPpl <= playstyle.minworkers && getFreePplCount() != 0){
      logger("Minworkers hit, playing now");
      setSpawnAction();
      setBuildingAction(checkBuildings());
      setResourceAction(village.resources);
      for (var k in eventQueue){
        launchAction(k);
      }
      for (var k in currentEvent){
        eventQueue.remove(k);
      }
    }
    else{
      List<Map> eventsToDelete = [];
      for (var k in currentEvent){
        checkStatus(k);
        if (k["status"] == "finished"){
          eventsToDelete.add(k);
          clearAction(k);
        }
      }
      for (Map k in eventsToDelete){
        currentEvent.remove(k);
      }
    }
    logger("----- AIPlayer n°${village.name} STOPPED PLAYING ----");

  }


  checkForDeadUnits(){
    Map<String, List<String>> unitToDelete = {"a": [], "h" : [], "v" : [], "s" : []};
    for (var key in freeUnits.keys){
      for (var unit in freeUnits[key]!){
        if (village.deads.containsKey(key) && village.deads[key]!.containsKey(unit)){
          unitToDelete[key]!.add(unit);
        }
      }
    }
    for (var key in unitToDelete.keys){
      for (var unit in unitToDelete[key]!){
        freeUnits[key]!.remove(unit);
      }
    }

  }

  Map<String, int> checkBuildings() {
    return {
      'A': village.community["A"]?.length ?? 0,
      'B': village.community["B"]?.length ?? 0,
      'C': village.community["C"]?.length ?? 0,
      'F': village.community["F"]?.length ?? 0,
      'H': village.community["H"]?.length ?? 0,
      'K': village.community["K"]?.length ?? 0,
      'S': village.community["S"]?.length ?? 0,
      'T': village.community["T"]?.length ?? 0,
    };
  }


  Map<String, int> checkUnits() {
    return {
      'a': village.community["a"]?.length ?? 0,
      'h': village.community["h"]?.length ?? 0,
      's': village.community["s"]?.length ?? 0,
      'v': village.community["v"]?.length ?? 0,
    };
  }

  List<int> getBuildingsPriority() {
    return [
      playstyle.playStyleMatrix[0][1],
      playstyle.playStyleMatrix[1][1],
      playstyle.playStyleMatrix[2][1]
    ];
  }

  List<int> getResourcesPriority() {
    return [
      playstyle.playStyleMatrix[0][0],
      playstyle.playStyleMatrix[1][0],
      playstyle.playStyleMatrix[2][0]
    ];
  }

  List<int> getPlayingPriority() {
    return [
      playstyle.playStyleMatrix[0][2],
      playstyle.playStyleMatrix[1][2],
      playstyle.playStyleMatrix[2][2]
    ];
  }

  bool isAffordable(Map<String, int> costDict) {
    var villageResource = village.resources;
    for (var entry in costDict.entries) {
      if ((villageResource[entry.key] ?? 0) <= entry.value) {
        return false;
      }
    }
    return true;
  }

  (int, int) estimateDistance((int, int) pos1, (int, int) pos2) {
    return ((pos2.$1 - pos1.$1).abs(), (pos2.$2 - pos1.$2).abs());
  }

  Map<(int,int), Resources> getNearestRessource((int, int) topLeftPos, String resourceType) {
    var resources = world.resources[resourceType];
    if (resources == null || resources.isEmpty) return {};

    var ressourceKeys = resources.keys.toList();
    var resourcePositions = resources.values.map((res) => estimateDistance(res.position, topLeftPos)).toList();

    if (resourcePositions.isEmpty) return {};

    int nearestIndex = resourcePositions.indexOf(resourcePositions.reduce((a, b) => a.$1 + a.$2 < b.$1 + b.$2 ? a : b));
    return {ressourceKeys[nearestIndex]: resources[ressourceKeys[nearestIndex]]!};
  }

  dynamic getNearestDropPoint(Map<(int,int), Resources> resource) {
    logger("Drops points aaare");
    List<(String,(int,int))> dropPoints = village.community["T"]?.entries.map((e) => (e.key,estimateDistance(e.value.position, resource.keys.first))).toList() ?? [];
    if (dropPoints.isEmpty) return -1;
    dropPoints.sort((a,b) => a[1].compareTo(b[1]));
    (String, (int,int)) test = dropPoints[0];

    return village.community["T"]?[test[0]];
  }

  int getOptimalBuildingCurve(String buildingType) {
    return 3;
  }

  int getFreePplCount() {
    return (freeUnits["v"]?.length ?? 0) + (freeUnits["s"]?.length ?? 0) +
        (freeUnits["h"]?.length ?? 0) + (freeUnits["a"]?.length ?? 0);
  }

  bool isOutOfBound((int, int) position) {
    return (position.$1 < 0 || position.$1 > world.width) ||
        (position.$2 < 0 || position.$2 > world.height);
  }

  List<String> getFreePeople(int number, String type) {
    int realNumber = (freeUnits[type]?.length ?? 0) > number ? number : (freeUnits[type]?.length ?? 0);
    return freeUnits[type]?.sublist(0, realNumber) ?? [];
  }

  bool checkIfTilesAreOccupied((int, int) size, (int, int) position) {
    for (var tile in getOccupiedTiles(size, position)) {
      if (world.tiles.containsKey(tile)) {
        return true;
      }
    }
    return false;
  }

  List<(int, int)> getOccupiedTiles((int, int) size, (int, int) position) {
    return [
      for (int x = 0; x < size.$1; x++)
        for (int y = 0; y < size.$2; y++)
          (position.$1 + x, position.$2 + y)
    ];
  }

  (int, int)? findLocationContour((int, int) size) {
    int w = size.$1 + 1;
    int h = size.$2 + 1;
    Set<(int, int)> candidates = {};
    List<dynamic> allBuildings = [];

    for (var buildingType in buildingENUM.keys) {
      allBuildings.addAll(village.community[buildingType]?.values ?? []);
    }

    for (var building in allBuildings) {
      var (bx, by) = building.position;
      var (bw, bh) = (building.surface.$1, building.surface.$2);
      candidates.addAll({
        (bx - w, by), (bx + bw, by), (bx, by - h), (bx, by + bh)
      });
    }

    for (var (x, y) in candidates) {
      if (!checkIfTilesAreOccupied(size, (x, y))) {
        return (x, y);
      }
    }
    return null;
  }

  (int, int)? getBuildTarget((int, int) size, [int tries = 0]) {
    var selectedPos = findLocationContour(size);
    if (selectedPos != null) {
      return selectedPos;
    }

    // If no positions are found, expand the village
    logger("AIPlayer | getBuildTarget---- Time to expand village border");

    return null;
  }

  dynamic getBuildingActionDict(String buildingType) {
    String villagerType = "v";
    List<String> idList = getFreePeople(getOptimalBuildingCurve("1"), villagerType);
    if (idList.isEmpty) {
      logger("LISTE D'UNITES LIBRE VIDE !!!!");
      return -1;
    }

    for (var i in idList) {
      freeUnits[villagerType]?.remove(i);
    }
    logger("getBuildingActionDict--- buildingType is ${buildingType}");
    var buildTarget = getBuildTarget((BuildingFactory.getSize(buildingType))!);
    String nextBuildingID = village.getNextUID("b");
    if (buildTarget == null) {
      return -1;
    }

    return {
      "action": "Build",
      "people": idList,
      "status": "pending",
      "infos": {
        "type": buildingType,
        "target": buildTarget,
        "buildingID" : nextBuildingID
      }
    };
  }

  Map<String, dynamic> getResourcesActionDict(Map<(int,int), Resources> resourceToCollect, String type, dynamic nearestDP) {
    logger("AIPlayer | getResourcesActionDict--- restoCollectVariable : $resourceToCollect");

    if (resourceToCollect.isEmpty) {
      throw Exception("No resources to collect");
    }

    (int,int) resKey = resourceToCollect.keys.first;
    Resources resourceInstance = world.resources[type]![resKey]!;

    List<String> unitID = getFreePeople(1, "v");

    if (unitID.isEmpty) {
      Map<String, dynamic> errorDict = {
        "action": "collectResource",
        "infos": {
          "type": type,
          "target": "ERROR",
          "targetKey": "ERRORR",
        }
      };
      throw Exception(errorDict);
    }

    for (var i in unitID) {
      freeUnits["v"]?.remove(i);
    }

    return {
      "action": "collectResource",
      "people": unitID,
      "status": "pending",
      "infos": {
        "type": type,
        "target": resourceInstance.position,
        "targetKey": resKey,
        "nearestDP": nearestDP,
        "quantity": resourceInstance.quantity,
      }
    };
  }

  Map<String, dynamic> getHumanActionDict(List<String> units, String type, Unit targetUnit) {
    return {
      "action": "attackAction",
      "people": units,
      "status" : "pending",
      "infos": {
        "unitType": type,
        "targetType": targetUnit.name,
        "target": targetUnit.position,
        "targetID": targetUnit.uid,
        "targetTeam": targetUnit.team,
      }
    };
  }

  Map<String, dynamic> getSpawnActionDict(String type, (int,int) buildingPos) {
    String nextUnitID = village.getNextUID("p");
    return {
      "action": "spawnAction",
      "infos": {
        "unitType": type,
        "unitSpawnPosition": (buildingPos[0]-1, buildingPos[1]-1),
        "futureID" : nextUnitID,
        "team": village.name,
      }
    };
  }

  /// Part where I set the actions
  void setResourceAction(Map<String, int> concernedRes) {
    List<int> resPriority = getResourcesPriority();
    resPriority = [
      resPriority[0] * level,
      resPriority[1] * level,
      resPriority[2] * level
    ];

    var resDistance = {
      "w": concernedRes["w"]! - resPriority[0],
      "g": concernedRes["g"]! - resPriority[1],
      "f": concernedRes["f"]! - resPriority[2]
    };

    String resourceToGet = resDistance.keys.reduce(
            (a, b) => resDistance[a]! < resDistance[b]! ? a : b);

    logger("Ressource to get is ${resourceTypeENUM[resourceToGet]}");

    Map<(int,int), Resources> resToCollect = getNearestRessource(topVillageBorder, resourceToGet);
    logger("AIPlayer | setResourceAction--- resToCollectValue $resToCollect");

    var nearestDP = getNearestDropPoint(resToCollect);
    logger("AIPlayer | setResourceAction--- nearestDP Is, $nearestDP");

    if (resToCollect == -1) {
      return;
    }

    if (nearestDP == {-1: -1}) {
      return;
    }

    try {
      Map<String,dynamic> resourceCollectEvent = getResourcesActionDict(resToCollect, resourceToGet, nearestDP);
      logger("Added the following resCollect event : \n Type :  ${resourceCollectEvent["infos"]["type"]}, \t nbOfPpl : , ${resourceCollectEvent["people"].length}, \t Position of the resource :, ${resourceCollectEvent["infos"]["target"]}");

      logger("AIPlayer | setResourceAction--- resourceCollectEvent,  resourceCollectEvent");

      eventQueue.add(resourceCollectEvent);
    } catch (e) {
      logger("AIPlayer | setResourceAction--- Not enough people to collectResource");
    }
  }

  void setBuildingAction(Map<String, int> buildings) {
    if (buildings["T"] == 0) {
      var buildingEvent = getBuildingActionDict("T");
      eventQueue.add(buildingEvent);
      return;
    } else {
      var buildingPriority = getBuildingsPriority();
      var builtBuildings = [
        buildings["A"]! + buildings["K"]! + buildings["S"]! + buildings["B"]!,
        buildings["H"]! + buildings["T"]!,
        buildings["F"]! + buildings["C"]!
      ];

      var buildingObjectiveDistance = {
        "Military": builtBuildings[0] - buildingPriority[0],
        "Village": builtBuildings[1] - buildingPriority[1],
        "Farming": builtBuildings[2] - buildingPriority[2]
      };

      String leastDeveloppedBuildingType = buildingObjectiveDistance.keys.reduce(
              (a, b) => buildingObjectiveDistance[a]! < buildingObjectiveDistance[b]! ? a : b);

      if (buildingObjectiveDistance[leastDeveloppedBuildingType] == 0) {
        return;
      } else {
        String leastDeveloppedBuildingName = "0";
        int leastDeveloppedBuildingNumber = 0;

        for (var i in buildingTypeENUM[leastDeveloppedBuildingType]!) {
          if ((buildings[buildingENUM[i]!] ?? 0) < leastDeveloppedBuildingNumber || leastDeveloppedBuildingName == "0") {
            leastDeveloppedBuildingName = buildingENUM[i]!;
            leastDeveloppedBuildingNumber = buildings[buildingENUM[i]!] ?? 0;
          }
        }
        logger("AIPlayer | SetBuildingAction--- leastDeveloppedBLD is ${leastDeveloppedBuildingName}");
        if (!isAffordable(buildingCostENUM[leastDeveloppedBuildingName]!)) {
          logger("Can't afford building");
          return;
        }

        var buildingEvent = getBuildingActionDict(leastDeveloppedBuildingName);

        if (buildingEvent == -1) {
          logger("No free units");
          return;
        }
        logger("Added the following building event : \n Type : ${buildingEvent["infos"]["type"]} \t nbOfPpl : ${buildingEvent["people"].length}");
        eventQueue.add(buildingEvent);
      }
    }
  }

  List<List<dynamic>> getBestAvailbleUnits() {
    List<List<dynamic>> unitRanking = [
      ["h", 4.8],
      ["a", 4],
      ["s", 3.6],
      ["v", 1.6]
    ];

    List<List<dynamic>> unitAvaibility = [];

    for (var u in unitRanking) {
      String unitType = u[0];
      int unitCount = village.community[unitType]?.values.length ?? 0;
      unitAvaibility.add([unitType, unitCount]);
    }

    return unitAvaibility;
  }

  void setHumanAction() {
    (int,int) nearestVillageDistance = (10000, 10000);
    Village? nearestVillage;

    for (var a in world.villages) {
      if (a.name == village.name) {
        continue;
      }

      String firstTargetTCKey = a.community["T"]!.keys.first;
      String firstTCKey = village.community["T"]!.keys.first;
      TownCenter firstTargetTC = a.community["T"]![firstTargetTCKey]!;
      TownCenter firstTC = village.community["T"]![firstTCKey]!;

      (int,int) villageDistance = estimateDistance(firstTC.position, firstTargetTC.position);

      if (villageDistance[0] < nearestVillageDistance[0] &&
          villageDistance[0] < nearestVillageDistance[1]) {
        nearestVillageDistance = villageDistance;
        nearestVillage = a;
      }
    }

    var unitAvaibilty = getBestAvailbleUnits();
    logger("AIPlayer | setHumanAction--- available unit by level : $unitAvaibilty");

    String selectedType = "v";

    for (var a in unitAvaibilty) {
      if (a[1] > 0) {
        logger("AIPlayer | setHumanAction--- there is ${a[1]} ${a[0]} ");
        selectedType = a[0];
        break;
      }
    }

    logger("AIPlayer | setHumanAction--- at the end selected type is :  $selectedType");
    List<String> unitList = getFreePeople(1, selectedType);
    if (unitList.isEmpty) {
      logger("AIPlayer | setHumanAction--- Not enough people to Attack");
      return;
    }

    for (var u in unitList) {
      freeUnits[selectedType]!.remove(u);
    }
    String firstUnitKey = nearestVillage!.community["v"]!.keys.first;
    var firstUnit = nearestVillage.community["v"]![firstUnitKey];
    logger("AIPlayer | setHumanAction--- we are going to attack $firstUnit");

    var actionDict = getHumanActionDict(unitList, selectedType, firstUnit);
    logger("Added the following attack event : \n Target : ${actionDict["infos"]["targetID"]} \t nbOfPpl : , ${actionDict["people"].length},\t Position of the target :, ${actionDict["infos"]["target"]}");

    eventQueue.add(actionDict);
  }

  void setSpawnAction(){
    if (spawningUnit > 4 || village.getMaxUnitNumber() == village.getUnitNumber()){
      logger("AIPlayer | setSpawnAction--- too much unit are being trained at the moment or there is no more place");
      return;
    }
    List<int> unitsPriority = getBuildingsPriority();
    int unitSum = unitsPriority.reduce((a,b) => a+b);
    List<double> coefficients = [(unitsPriority[0]/unitSum),(unitsPriority[1]/unitSum),(unitsPriority[2]/unitSum)];
    List<int> flooredUnitsPriority = [(coefficients[0]*200).toInt(),(coefficients[1]*200).toInt(),(coefficients[2]*200).toInt()];
    Map<String,Map<String, dynamic>> villageCommunity = village.community;
    var spawnedUnits = [
      (villageCommunity["a"]?.length ?? 0) + (villageCommunity["h"]?.length ?? 0) +  (villageCommunity["s"]?.length ?? 0),
      (villageCommunity["v"]?.length ?? 0),
      (villageCommunity["v"]?.length ?? 0),
    ];
    Map<String, int> unitObjectiveDistance = {
      "Military": spawnedUnits[0] - flooredUnitsPriority[0],
      "Village": spawnedUnits[1] - flooredUnitsPriority[1],
      "Farming": spawnedUnits[2] - flooredUnitsPriority[2]
    };
    List<(String,int)> unitTypeRanking = unitObjectiveDistance.entries.map((e) => (e.key, e.value)).toList();
    unitTypeRanking.sort((a,b) => a[1].compareTo(b[1]));
    logger("AIPlayer | setSpawnAction--- unitRanking is $unitTypeRanking");
    String leastDeveloppedUnitType = unitTypeRanking[0][0];
    logger("AIPlayer | setSpawnAction--- leastDeveloppedUnitType is $leastDeveloppedUnitType");
    List<(String, int)> unitRanking = unitTypeENUM[leastDeveloppedUnitType]!.map((e) => (e, villageCommunity[e]?.length ?? 0)).toList();
    unitRanking.sort((a,b) => a[1].compareTo(b[1]));
    logger("AIPlayer | setSpawnAction--- least developped unit is ${unitRanking[0]}");
    bool foundUnitToSpawn = false;
    String unitToSpawn = "";
    String buildingToSpawn = "";
    for (int i=0; i<unitTypeRanking.length && !foundUnitToSpawn; i++){
      for (var type in unitRanking){
        Map<String,int>? unitCost = UnitFactory.getUnitCost(type[0]);
        String? buildingToSpawnFrom = BuildingFactory.getBuildingToSpawnFrom(type[0]);
        if (unitCost != null && buildingToSpawnFrom != null){
          if (isAffordable(unitCost) && village.getBuildingCount(buildingToSpawnFrom) != 0){
            foundUnitToSpawn = true;
            buildingToSpawn = buildingToSpawnFrom;
            unitToSpawn = type[0];
            break;
          }
        }
        unitRanking = unitTypeENUM[unitTypeRanking[i][0]]!.map((e) => (e, villageCommunity[e]?.length ?? 0)).toList();
        unitRanking.sort((a,b) => a[1].compareTo(b[1]));
      }
    }
    if (unitToSpawn == ""){
      logger("AIPlayer | setSpawnAction--- Not enough resources to spawn any unit");
      return;
    }
    logger("AIPlayer | setSpawnAction--- choosen unit to spawn is ${unitToSpawn}");
    (int,int) buildingPos = village.community[buildingToSpawn]!.values.first.position;
    Map<String,dynamic> event = getSpawnActionDict(unitToSpawn,buildingPos);

    eventQueue.add(event);
  }


  /// Now for the part which launches the actions
  void launchSpawnAction(Map<String, dynamic> actionDict){
    String unitType = actionDict["infos"]["unitType"];
    (int,int) buildingPos = actionDict["infos"]["unitSpawnPosition"];
    logger("AIPlayer | launchSpawnAction--- Spawned new ${unitType} (${actionDict["infos"]["futureID"]}) for ${village.name} at ${buildingPos}");
    spawningUnit ++;
    gameManager.addUnitToSpawnDict(unitType, village.name, buildingPos);
    currentEvent.add(actionDict);
    //eventQueue.remove(actionDict);
  }

  void launchResourceAction(Map<String,dynamic> actionDict){

    List<String> deadUnits = [];
    for (String unit in actionDict["people"]){
      if (village.deads.containsKey(unit)){
        deadUnits.add(unit);
      }
    }
    for (String id in deadUnits){
      actionDict["people"].remove(id);
    }
    for (String id in actionDict["people"]){
      Unit unitInstance = village.community["v"]![id];
      Resources resourcesInstance= world.resources[actionDict["infos"]["type"]]![actionDict["infos"]["target"]]!;
      (int,int) resPos = gameManager.addResourceToCollectDict(unitInstance, resourcesInstance, actionDict["infos"]["nearestDP"], actionDict["infos"]["quantity"]);
      gameManager.addUnitToMoveDict(unitInstance, resPos);
    }
    currentEvent.add(actionDict);
    //eventQueue.remove(actionDict);
  }

  void launchBuildAction(Map<String,dynamic> actionDict){
    String nextBuildingID = village.getNextUID("b");
    Building? newBuilding = BuildingFactory.createBuilding(actionDict["infos"]["type"], nextBuildingID, actionDict["infos"]["target"], village.name);
    logger("AIPlayer | launchBuildAction--- New BuildingID is ${nextBuildingID}");
    if (newBuilding == null){
      logger("AIPlayer | launchBuildAction--- The new building seems to be null, cancelling action");
      return;
    }
    (int,int)? newBuildingBuildPos =  gameManager.getEmptyTile(newBuilding.position).firstOrNull;
    if (newBuildingBuildPos == null){
      logger("AIPlayer | launchBuildAction--- No empty tiles near the building, cancelling the action.");
      return;
    }
    for (String id in actionDict["people"]){
      Unit unitInstance = village.community["v"]![id];
      gameManager.addUnitToMoveDict(unitInstance, newBuildingBuildPos);
      freeUnits["v"]!.remove(id);
    }
    logger("AIPlayer | launchBuildAction--- Added ${actionDict["people"]}");
    newBuilding.health = 0;
    int buildResult  = village.addBuilding(newBuilding);
    if (buildResult < 0){
      logger("AIPlayer | launchBuildAction--- Error while adding the building to the village, and to the world, cancelling action");
    }
    logger("Added the building to the willage");
    gameManager.addBuildingToBuildDict(newBuilding, actionDict["people"]);
    logger("The build dict entry is : ${gameManager.buildDict[nextBuildingID]}");
    logger("Added the building to the buildDict, adding to currentEvent");
    currentEvent.add(actionDict);
    //eventQueue.remove(actionDict);
  }

  void launchHumanAction(Map<String,dynamic> actionDict){
    List<Unit> unitList = [];
    for (String id in actionDict["people"]){
      Unit unitInstance = village.community[actionDict["infos"]["unitType"]]![id]!;
      gameManager.addUnitToMoveDict(unitInstance, actionDict["infos"]["target"]);
    }
    Unit? targetUnit = world.getVillage(actionDict["infos"]["targetTeam"]).community[actionDict["infos"]["targetType"]]?[actionDict["infos"]["targetID"]];
    if (targetUnit == null){
      logger("LaunchHumanAction --- unit doesnot exists");
      return;
    }
    gameManager.addUnitToAttackDict(unitList, targetUnit);
    currentEvent.add(actionDict);
    //eventQueue.remove(actionDict);
  }

  void launchAction(Map<String,dynamic> actionDict){
    Map<String, Function> launchActionENUM ={
      "Build" : (Map<String, dynamic> actionDict) => launchBuildAction(actionDict),
      "collectResource" : (Map<String, dynamic> actionDict) => launchResourceAction(actionDict),
      "attackAction" : (Map<String, dynamic> actionDict) => launchHumanAction(actionDict),
      "spawnAction" : (Map<String, dynamic> actionDict) => launchSpawnAction(actionDict)
    };

    launchActionENUM[actionDict["action"]]!(actionDict);
  }

  void checkBuildingAction(Map<String, dynamic> event) {
    String bldID = event["infos"]["buildingID"];
    logger("AIPlayer | checkBuildingAction--- BldID is $bldID");
    if (gameManager.checkBuildingStatus(bldID)) {
      logger(gameManager.buildDict[bldID]);
      logger("Finished building ${bldID}");
      event["status"] = "finished";
    }
  }

  void checkResourceAction(Map<String, dynamic> event) {
    logger("AIPlayer | checkResourceAction--- Event is ${event}");
    String targetRes = event["people"].first;
    if (gameManager.checkResourceStatus(targetRes)) {
      logger("Finished collecting ${targetRes}");
      event["status"] = "finished";
    }
  }

  void checkAttackAction(Map<String, dynamic> event) {
    List unitID = event["people"];
    bool finishedEvent = false;

    for (var i in unitID) {
      finishedEvent = gameManager.checkAttackStatus(i);
    }

    if (finishedEvent) {
      logger("Finished attacking ${event["infos"]["targetID"]}");
      event["status"] = "finished";
    }
  }

  void checkUnitSpawnAction(Map<String, dynamic> event) {
    logger("AIPlayer | checkUnitSpawnAction--- checking units");
    String unitID = event["infos"]["futureID"];
    logger("AIPlayer | checkUnitSpawnAction--- checking if unit ${unitID} is fully trained");
    if (gameManager.checkSpawnStatus(unitID)) {
      logger("Unit ${unitID} is fully trained and ready to be added to the team");
      event["status"] = "finished";
    }
  }

  void checkStatus(Map<String, dynamic> event){
    Map<String, Function> checkActionENUM ={
      "Build" : (Map<String, dynamic> actionDict) => checkBuildingAction(actionDict),
      "collectResource" : (Map<String, dynamic> actionDict) => checkResourceAction(actionDict),
      "attackAction" : (Map<String, dynamic> actionDict) => checkAttackAction(actionDict),
      "spawnAction" : (Map<String, dynamic> actionDict) => checkUnitSpawnAction(actionDict)
    };
    checkActionENUM[event["action"]]!(event);

  }

  void clearAction(Map<String, dynamic> event){
    Map<String, Function> checkActionENUM ={
      "Build" : (Map<String, dynamic> actionDict) => clearBuildAction(actionDict),
      "collectResource" : (Map<String, dynamic> actionDict) => clearResourcesActions(actionDict),
      "attackAction" : (Map<String, dynamic> actionDict) => clearAttackAction(actionDict),
      "spawnAction" : (Map<String, dynamic> actionDict) => clearUnitSpawnAction(actionDict)
    };
    checkActionENUM[event["action"]]!(event);

  }

  void clearBuildAction(Map<String, dynamic> event){
    for (String unit in event["people"]){
      logger("AIPlayer | clearBuildAction--- freeing ${unit}");
      freeUnits.putIfAbsent("v", ()=>[]);
      freeUnits["v"]!.add(unit);
    }
  }

  void clearResourcesActions(Map<String, dynamic> event){
    for (String unit in event["people"]){
      freeUnits.putIfAbsent("v", ()=>[]);
      freeUnits["v"]!.add(unit);
    }
  }

  void clearAttackAction(Map<String, dynamic> event){
    String unitType = event["infos"]["unitType"];
    for (String unit in event["infos"]["unitType"]){
      freeUnits.putIfAbsent(unitType, ()=>[]);
      freeUnits[unitType]!.add(unit);
    }
  }

  void clearUnitSpawnAction(Map<String, dynamic> event){
    logger("AIPlayer | clearUnitSpawnAction--- Now adding the unit to freeunits");
    String unitID = event["infos"]["futureID"];
    String unitType = event["infos"]["unitType"];
    spawningUnit--;
    freeUnits.putIfAbsent(unitType, ()=>[]);
    freeUnits[unitType]!.add(unitID);
  }





}
