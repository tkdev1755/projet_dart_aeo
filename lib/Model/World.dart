

import 'package:projet_dart_aeo/Model/Village.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:projet_dart_aeo/Model/resources.dart';
import 'package:projet_dart_aeo/Model/tile.dart';
import 'package:projet_dart_aeo/Model/unit.dart';

import '../projet_dart_aeo.dart';

class World{
  int width;
  int height;
  Map<Record, Tile> tiles = {};
  Map<Record, Unit> unitPositions = {};
  Map<Record, Resources> resources = {};
  Map<String, Village> villages = {};

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
      if (checkIfOccupied(occupiedTiles)){
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
      if (tiles[element.position]!.contains == Null){
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
      tiles[element.position]!.contains = element;
      return 0;
    }
  }

  bool isOutOfBound((int,int) element){
    print("Element position is $element}");
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

  String reprWorld(){
    String fString = "";
    for (int x=0; x<=width; x++){
      for (int y = 0; y<=height;y++){
        if (tiles.containsKey((x,y)) && tiles[(x,y)]!.contains != null) {
          fString += tiles[(x,y)]!.contains.toString();
        } else {
          fString += " ";
        }
      }
    }
    return fString;
  }
}

