

import 'package:projet_dart_aeo/Controller/gameManager.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:projet_dart_aeo/Model/resources.dart';

import 'Village.dart';
import 'World.dart';

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
    List tcList = village.community["T"]?.values.toList() ?? [];
    tcs = tcList as List<TownCenter>;
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

  dynamic getNearestDropPoint(Map<String, (int, int)> resource) {
    var dpKeys = village.community["T"]?.keys.toList() ?? [];
    var dropPoints = village.community["T"]?.values.map((dp) => estimateDistance(dp.position.toRecord(), resource.values.first)).toList() ?? [];

    if (dropPoints.isEmpty) return -1;

    int nearestIndex = dropPoints.indexOf(dropPoints.reduce((a, b) => a.$1 + a.$2 < b.$1 + b.$2 ? a : b));
    return village.community["T"]?[dpKeys[nearestIndex]];
  }




}