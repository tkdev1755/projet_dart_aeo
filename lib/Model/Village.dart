



import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:projet_dart_aeo/Model/unit.dart';
import 'package:projet_dart_aeo/projet_dart_aeo.dart';

import 'World.dart';

Map<String, dynamic> bStaticDict = {
  "T" : TownCenter,

};
class Village{
  int name;
  World world;
  int pplCount = 0;
  int buildingCount = 0;
  Map<String, Map<String,dynamic>> community = {};
  Map<String, int> resources = {"w" : 0, "g" : 0, "f" : 0};

  Village(
      this.name,
      this.world,
      ){
    world.addVillage(this);
  }
  
  String getNextUID(String type){
    if (type != "b" && type != "p") return "";
    return "eq$name$type${(type=="p" ? pplCount : buildingCount)+1}";
  }


  int getMaxUnitNumber(){
    int tcNumber = community["T"]?.length ?? 0;
    int hNumber = community["H"]?.length ?? 0;
    return tcNumber*5 + hNumber*5;
  }
  int getUnitNumber(){
    int aNumber = community["a"]?.length ?? 0;
    int hNumber = community["h"]?.length ?? 0;
    int sNumber = community["s"]?.length ?? 0;
    int vNumber = community["v"]?.length ?? 0;
    return aNumber+hNumber+sNumber+vNumber;
  }
  
  bool canAfford(Map<String, int> costDict){
    for (var value in costDict.entries){
      if (value.value > (resources[value.key]!)){
        return false;
      }
    }
    return true;
  }
  
  bool isThereRoom(){
    return getUnitNumber() < getMaxUnitNumber();
  }

  int addResources(String type, int quantity){
    if (resources.containsKey(type)){
      resources[type]  = resources[type]!+quantity;
      return 0;
    }
    else{
      resources[type] = 0;
      resources[type]  = resources[type]!+quantity;
      return 0;
    }
  }
  
  int addBuilding(Building building){
    int addResult = world.addElement(building);
    if (addResult == -1){
      return -1;
    }
    if (!canAfford(building.cost)) {
      logger("Can't afford building");
      return -1;
    }
    if (community.containsKey(building.name)){
      community[building.name]![building.uid] = building;
    }
    else{
      community[building.name] ={};
      community[building.name]![building.uid] = building;
    }
    deductResources(building.cost);
    buildingCount++;
    return 0;
  }

  int addUnit(Unit unit){
    if (!isThereRoom()){
      logger("No room to add a unit ");
      return -1;
    }
    if (!canAfford(unit.cost)) {
      logger("Can't afford the unit");
      return -1;
    }
    world.addUnit(unit);
    if (community.containsKey(unit.name)){
      community[unit.name]![unit.uid] = unit;
    }
    else{
      community[unit.name] ={};
      community[unit.name]![unit.uid] = unit;
    }
    deductResources(unit.cost);
    pplCount++;
    return 0;
  }

  int deductResources(Map<String, int> costDict){
    for (var value in costDict.entries){
      if ((resources[value.key] ?? 0) < value.value){
        logger("Shouldn't called this function ?");
        return -1;
      }
      resources[value.key] = resources[value.key]! - value.value;
    }
    return 1;
  }
}