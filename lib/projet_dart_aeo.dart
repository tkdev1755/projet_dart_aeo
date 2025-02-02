import 'package:projet_dart_aeo/Model/World.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';

bool debug = true;

extension RecordIndexing<T1, T2> on (T1, T2) {
  dynamic operator [](int index) {
    switch (index) {
      case 0:
        return this.$1;
      case 1:
        return this.$2;
      default:
        throw RangeError("Invalid index $index for a record of length 2.");
    }
  }
}

void logger(String str){
  if (debug){
    print(str);
  }
}

int calculate() {
  World world = World(120, 120);
  TownCenter tc1 = TownCenter("eq1p2", (0,0));
  int result = world.addElement(tc1);
  if (result == -1){
    logger("ERRoR");
    return -1;
  }
  print(world.reprWorld());
  return 6 * 7;
}
