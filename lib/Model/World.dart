

import 'package:projet_dart_aeo/Model/Village.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:projet_dart_aeo/Model/resources.dart';
import 'package:projet_dart_aeo/Model/tile.dart';
import 'package:projet_dart_aeo/Model/unit.dart';

import '../projet_dart_aeo.dart';

class World{
  int width;
  int height;
  Map<(int,int), Tile> tiles = {};
  Map<(int,int), List<Unit>> unitPositions = {};
  Map<String,Map<(int,int), Resources>> resources = {};
  List villages = [];

  World(
      this.width,
      this.height,
      );


  int addElement(dynamic element){
    if (isOutOfBound(element.position)) {
      logger("Object is out of bounds");
      return -1;
    }
    if (element is Building){
      logger("IT'S A BULDING !");
      List<(int,int)> occupiedTiles = element.getOccupiedTiles();
      if (!checkIfOccupied(occupiedTiles)){
        logger("Apparently there is something in the way");
        // ADD Exception
        return -1;
      }
      else{
        for (var value in occupiedTiles) {
          if (tiles.containsKey(value)){
            tiles[value]!.contains = element;
          }
          else{
            tiles[value] = Tile(value);
            tiles[value]!.contains = element;
          }
        }
        return 0;
      }
    }

    if (tiles.containsKey(element.position)){
      if (tiles[element.position]!.contains == null){
        if (element is Resources){
          resources.putIfAbsent(element.name, ()=>{});
          resources[element.name]![element.position] = element;
        }
        tiles[element.position]!.contains = element;
        return 0;
      }
      else{
        /* NEED TO ADD EXCEPTION */
        return -1;
      }
    }
    else{
      tiles[element.position] = Tile(element.position);
      if (element is Resources){
        resources.putIfAbsent(element.name, ()=>{});
        resources[element.name]![element.position] = element;
      }
      tiles[element.position]!.contains = element;
      return 0;
    }

  }
  int addUnit(Unit unit){
    if (!(unitPositions.containsKey(unit.position))){
      logger("key does not exists");
      unitPositions[unit.position] = [];
      unitPositions[unit.position]!.add(unit);
    }
    else{
      unitPositions[unit.position]!.add(unit);
    }
    return 0;
  }

  int addVillage(Village village){
    try {
      logger("Adding village");
      villages.add(village);
    } catch (e, s) {
      logger(s.toString());
      return -1;
    }
    return 0;
  }

  int updateUnitPosition((int,int) oldPos,Unit unit){
    if (unitPositions.containsKey(unit.position)){
      unitPositions[unit.position]!.add(unit);
      if (unitPositions.containsKey(oldPos)){

        unitPositions[oldPos]!.remove(unit);
        if (unitPositions[oldPos]!.isEmpty) {
          unitPositions.remove(oldPos);
        }
      }
    }
    else{
      unitPositions[unit.position] = [];
      unitPositions[unit.position]!.add(unit);
      unitPositions[oldPos]!.remove(unit);
      if (unitPositions[oldPos]!.isEmpty) {
        unitPositions.remove(oldPos);
      }
    }
    return 0;
  }

  bool isOutOfBound((int,int) element){
    logger("Element position is $element}");
    return (element[0] > width && element[1] > height) || (element[0] < 0 && element[1] < 0);
  }

  bool checkIfOccupied(List<(int,int)> positions){
    for (var value in positions) {
      if (tiles.containsKey(value) && tiles[value]!.contains != Null){
        return false;
      }
    }
    return true;
  }

  Village getVillage(int teamNumber){
    if (teamNumber-1 >villages.length){
      throw Exception("Village out of bounds");
    }
    return villages[teamNumber-1];
  }


  String reprWorld(int y ,int offsetX){
    String fString = "";
    for (int x=0+offsetX; x<=(console.windowWidth<width ? console.windowWidth : width)-1; x++){
      if (tiles.containsKey((x+offsetX,y)) && tiles[(x+offsetX,y)]!.contains != null) {
        fString += tiles[(x+offsetX,y)]!.contains.toString();
      }
      else if (unitPositions.containsKey((x+offsetX,y)) && unitPositions[(x+offsetX,y)]!.isNotEmpty){
        fString += unitPositions[(x+offsetX,y)]![0].toString();
      }
      else {
        fString += " ";
      }
    }
    return fString;
  }
}

