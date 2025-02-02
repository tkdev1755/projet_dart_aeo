


class Unit{
  String name;
  String uid;
  Record position;
  int health;
  int damage;
  double speed;
  String task;
  Map<String, int> pouch = {"w" : 0, "g" : 0};

  Unit(
      this.name,
      this.uid,
      this.position,
      this.health,
      this.damage,
      this.speed,
      this.task
      );
  @override
  int get hashCode => super.hashCode;
  @override
  String toString() {
    return name;
  }
}


class Villager extends Unit{


  Villager(
      String uid,
      Record position,
      ) : super("v", uid, position, 25, 2,0.8, 'I');

}