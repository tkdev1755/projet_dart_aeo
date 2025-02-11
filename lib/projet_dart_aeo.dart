
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:projet_dart_aeo/Controller/gameManager.dart';
import 'package:projet_dart_aeo/Model/World.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:dart_console/dart_console.dart';
import 'package:projet_dart_aeo/Model/resources.dart';
import 'package:projet_dart_aeo/Model/unit.dart';
import 'Model/Village.dart';
import 'package:console/console.dart' as CG;

import 'Model/randomMap.dart';

bool debug = false;
final console = Console();
final random = Random();
int offsetX = 0;
int offsetY = 0;
final int rows = console.windowHeight;
final int cols = console.windowWidth;
final int size = rows * cols;
String pressedKey  ="";
bool isPressed = false;
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


void logger(dynamic str){
  if (debug){
    print(str);
  }
}

int calculate() {
  
  return tests();
}


Map<int, CG.Color> colorMap = {
  1 : CG.Color.BLUE,
  2 : CG.Color.CYAN,
  3 : CG.Color.GOLD,
  4 : CG.Color.GREEN,
  5 : CG.Color.MAGENTA,
  6 : CG.Color.LIME,
  7 : CG.Color.DARK_BLUE,
  8 : CG.Color.LIGHT_CYAN,
  9 : CG.Color.YELLOW,
  10 : CG.Color.RED,
};

final buffer = StringBuffer();
bool done = false;

int tests(){
  World world = World(300, 300);
  world = randomWorld({"X" : 300, "Y":300, "t": "g"});
  Village village1 = Village(1, world);
  Village village2 = Village(2, world);
  village1.addResources("f", 5000);
  village1.addResources("w", 5000);
  village1.addResources("g", 5000);
  village2.addResources("f", 5000);
  village2.addResources("w", 5000);
  village2.addResources("g", 5000);
  String newTcID = village1.getNextUID("b");
  String newTCID2 = village2.getNextUID("b");
  if (newTcID == "" || newTCID2 == ""){
    logger("Object type wasn't ok");
    return -1;
  }
  TownCenter tc1 = TownCenter(newTcID, (15,40), village1.name);
  TownCenter tc21 = TownCenter(newTCID2, (40,10), village2.name);
  int result = village1.addBuilding(tc1);
  int result21 = village2.addBuilding(tc21);
  if (result == -1 || result21 == -1){
    logger("ERRoR");
    return -1;
  }
  String newTcID2 = village1.getNextUID("b");
  if (newTcID2 == ""){
    logger("Object type wasn't ok");
    return -1;
  }
  TownCenter tc2 = TownCenter(newTcID2, (12,12), village1.name);
  int result2 = village1.addBuilding(tc2);
  if (result2 <0){

  }
  String newVillagerUID = village1.getNextUID("p");
  String newVillager2UID = village2.getNextUID("p");
  if (newVillagerUID == ""){
    logger("Object type wasn't ok");
    return -1;
  }
  Villager newVillager = Villager(newVillagerUID, (0,2),village1.name);
  Villager newVillager2 = Villager(newVillager2UID, (39,9), village2.name);

  int result3 = village1.addUnit(newVillager);
  int result4 = village2.addUnit(newVillager2);
  if (result3 < 0 || result4 < 0){
  }
  GameManager gm = GameManager(world,DateTime.now());
  String newBuildingID = village1.getNextUID("b");
  TownCenter tc3 = TownCenter(newBuildingID, (4,20),village1.name);
  tc3.health = 0;
  village1.addBuilding(tc3);
  //gm.addBuildingToBuildDict(tc3, [newVillager.uid]);
  gm.addUnitToSpawnDict("v", 1);
  //gm.addUnitToMoveDict(newVillager2, (24,20));
  //gm.addUnitToMoveDict(newVillager, gm.moveDict[newVillager2.uid]!["goal"]);
  //gm.addUnitToAttackDict([newVillager], newVillager2);
  Resources res = Resources("w", 200, (23,23));
  world.addElement(res);
  (int,int) resPosition = gm.addResourceToCollectDict(newVillager, res, tc1, 10);
  gm.addUnitToMoveDict(newVillager, resPosition);

  //print(world.reprWorld());
  /*console.clearScreen();
  console.resetCursorPosition();

  console.write();*/
  gameLoop(world, gm);
  return 0;
}

void update(World world, GameManager gameManager){
  gameManager.checkModifications();
}

void resetConsole() {
  console.clearScreen();
  console.resetCursorPosition();
  console.resetColorAttributes();
  console.rawMode = false;
}

void draw(World world){
  console.clearScreen();
  buffer.clear();
  for (var row = 0; row < rows; row++) {
    buffer.write(world.reprWorld(row+offsetY,offsetX));
    buffer.write(console.newLine);
  }

  console.write(buffer.toString());
}






void quit() {
  resetConsole();
  exit(0);
}

readInput(List<int> args, GameManager gameManager) {
  Stream<String> upStream = CG.Keyboard.bindKey('up');
  Stream<String> downStream = CG.Keyboard.bindKey('down');
  Stream<String> rightStream = CG.Keyboard.bindKey('right');
  Stream<String> leftStream =CG.Keyboard.bindKey('left');
  Stream<String> plusStream =CG.Keyboard.bindKey('+');
  Stream<String> minusStream =CG.Keyboard.bindKey('-');
  Stream<String> escStream =CG.Keyboard.bindKey('esc');

  downStream.listen((_) {
    if (offsetY+console.windowHeight >= args[0]){

    }else{
      offsetY++;
    }
  });
  upStream.listen((event){
    if (offsetY == 0){
    }
    else{
      offsetY--;

    }
  });
  rightStream.listen((event){
    if (offsetX+console.windowWidth >= args[1]){
    }
    else{
      offsetX++;
    }
  });
  leftStream.listen((event){
    if (offsetX == 0){
    }
    else{
      offsetX--;
    }
  });
  plusStream.listen((event){
    if (gameManager.gameSpeed < 10){
      gameManager.gameSpeed ++;
    }
  });
  minusStream.listen((event){
    if (gameManager.gameSpeed > 1){
      gameManager.gameSpeed --;
    }
  });
  escStream.listen((event){
    print("escaping game");
    exit(0);
  });
}

gameLoop(World world, GameManager gameManager) async {

  CG.Keyboard.init();
  List<int> args = [world.height, world.width];
  console.rawMode = false;
  console.hideCursor();
  readInput(args, gameManager);
  try {
    console.rawMode = false;
    console.hideCursor();
    Timer.periodic(const Duration(milliseconds: 200), (t) {
      if (!debug){
        draw(world);
      }
      update(world, gameManager);
      gameManager.tick = DateTime.now();
      if (done) quit();
    });
  } catch (exception) {
    //crash(exception.toString());
    rethrow;
  }
}
