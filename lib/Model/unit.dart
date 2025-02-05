
import '../projet_dart_aeo.dart';

Map<String, int> unitHealthENUM = {
  "a" : 30,
  "h" : 45,
  "v" : 25,
  "s" : 40,
};

class Unit{
  String name;
  String uid;
  int team;
  (int,int) position;
  int health;
  int damage;
  double speed;
  String task;
  Map<String,int> cost = {};
  Map<String, int> pouch = {"w" : 0, "g" : 0};

  Unit(
      this.name,
      this.uid,
      this.team,
      this.position,
      this.health,
      this.damage,
      this.speed,
      this.task,
      {required this.cost}
      );
  @override
  int get hashCode => super.hashCode;
  @override
  String toString() {
    return "${health ==  unitHealthENUM[name]! ? colorMap[team] : colorMap[10]}$name${colorMap[9]}";
  }
}


class Villager extends Unit{


  Villager(
      String uid,
      (int,int) position,
      int team
      ) : super("v", uid,team, position, 25, 2,0.8, 'I',cost: {"f" : 50});

}