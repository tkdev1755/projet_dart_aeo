
import '../projet_dart_aeo.dart';

Map<String, int> unitHealthENUM = {
  "a" : 30,
  "h" : 45,
  "v" : 25,
  "s" : 40,
};

Map<String, int> unitTrainTimeENUM = {
  "a" : 35,
  "h" : 30,
  "v" : 25,
  "s" : 20,
};

class Unit{
  String name;
  String uid;
  int team;
  (int,int) position;
  int health;
  int damage;
  double speed;
  int range;
  String task;
  int trainingTime;
  Map<String,int> cost = {};
  Map<String, int> pouch = {"w" : 0, "g" : 0};

  Unit(
      this.name,
      this.uid,
      this.team,
      this.position,
      this.health,
      this.damage,
      this.range,
      this.speed,
      this.task,
      this.trainingTime,
      {required this.cost}
      );
  @override
  int get hashCode => super.hashCode;
  @override
  String toString() {
    return "${health ==  unitHealthENUM[name]! ? colorMap[team] : colorMap[10]}$name${colorMap[9]}";
  }

  int placeLeft(){
    return pouch.values.fold(0, (prev, element) => prev + element);
  }

  bool isFull(){
    return placeLeft() == 0;
  }
}


class Villager extends Unit{

  Villager(
      String uid,
      (int,int) position,
      int team
      ) : super("v", uid,team, position, 25, 2,1,0.8, 'I',25,cost: {"f" : 50});



}



class UnitFactory {
  static final Map<String, Function> unitInitDict = {
    "v": (uid,position,team) => Villager(uid,position,team),
  };

  static Unit? createUnit(String key, uid,position,team) {
    if (unitInitDict.containsKey(key)) {
      return unitInitDict[key]!(uid,position,team); // Call the constructor function
    }
    return null;
  }
}
