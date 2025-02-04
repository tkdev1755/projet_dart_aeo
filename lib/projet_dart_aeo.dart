import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:projet_dart_aeo/Controller/gameManager.dart';
import 'package:projet_dart_aeo/Model/World.dart';
import 'package:projet_dart_aeo/Model/buildings.dart';
import 'package:dart_console/dart_console.dart';
import 'package:projet_dart_aeo/Model/unit.dart';
import 'Model/Village.dart';
import 'package:console/console.dart' as CG;

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

final buffer = StringBuffer();
bool done = false;

int tests(){
  World world = World(300, 300);
  Village village1 = Village(1, world);
  logger("Village resources \n ${village1.resources}");
  village1.addResources("f", 5000);
  village1.addResources("w", 5000);
  village1.addResources("g", 5000);
  logger("Village resources \n ${village1.resources}");
  String newTcID = village1.getNextUID("b");
  if (newTcID == ""){
    logger("Object type wasn't ok");
    return -1;
  }
  TownCenter tc1 = TownCenter(newTcID, (15,40));
  int result = village1.addBuilding(tc1);
  if (result == -1){
    logger("ERRoR");
    return -1;
  }
  String newTcID2 = village1.getNextUID("b");
  if (newTcID2 == ""){
    logger("Object type wasn't ok");
    return -1;
  }
  TownCenter tc2 = TownCenter(newTcID2, (12,12));
  int result2 = village1.addBuilding(tc2);
  if (result2 <0){

  }
  String newVillagerUID = village1.getNextUID("p");
  if (newVillagerUID == ""){
    logger("Object type wasn't ok");
    return -1;
  }
  Villager newVillager = Villager(newVillagerUID, (0,2));
  int result3 = village1.addUnit(newVillager);
  if (result3 < 0){

  }
  GameManager gm = GameManager(world,DateTime.now());
  gm.addUnitToMoveDict(newVillager, (3,20));
  String newBuildingID = village1.getNextUID("b");
  TownCenter tc3 = TownCenter(newBuildingID, (4,20));
  tc3.health = 0;
  village1.addBuilding(tc3);
  gm.addBuildingToBuildDict(tc3, [newVillager.uid]);
  //print(world.reprWorld());
  /*console.clearScreen();
  console.resetCursorPosition();

  console.write();*/
  gameLoop(world, gm);
  return 0;
}

void update(World world, GameManager gameManager){
  gameManager.checkUnitToMove();
  gameManager.checkBuildingToBuild();
}

void resetConsole() {
  console.clearScreen();
  console.resetCursorPosition();
  console.resetColorAttributes();
  console.rawMode = false;
}

void draw(World world, ){
  console.clearScreen();

  buffer.clear();

  for (var row = 0; row < rows; row++) {
    buffer.write(world.reprWorld(row+offsetY,offsetX));
    buffer.write(console.newLine);
  }

  console.write(buffer.toString());
}





void input(int wHeight, int wWidth, Key key){
  if (key.isControl) {
    switch (key.controlChar) {
      case ControlCharacter.escape:
        print("escaping cgame");
        done = true;
        break;
      case ControlCharacter.arrowDown:
        print("offsetY Val : $offsetY, console height ${console.windowHeight}");
        if (offsetY+console.windowHeight >= wHeight){

        }else{
          print("going downnnn");
          offsetY++;
          print("offsetY Val : $offsetY");
        }
        break;
      case ControlCharacter.arrowUp:
        print("going uppp");
        if (offsetY == 0){
        }
        else{
          offsetY--;
          print("offsetY Val : $offsetY");
        }
        break;
      case ControlCharacter.arrowRight:
        print("offsetY Val : $offsetX, console height ${console.windowWidth}, world with ${wWidth}");

        if (offsetX+console.windowWidth >= wWidth){
        }
        else{
          offsetX++;
        }
        break;
      case ControlCharacter.arrowLeft:
        if (offsetX == 0){
        }
        else{
          offsetX--;
        }
      default:
    }
  }

}


void quit() {
  resetConsole();
  exit(0);
}

readInput(List<int> args) {
  Stream<String> upStream = CG.Keyboard.bindKey('up');
  Stream<String> downStream = CG.Keyboard.bindKey('down');
  Stream<String> rightStream = CG.Keyboard.bindKey('right');
  Stream<String> leftStream =CG.Keyboard.bindKey('left');
  Stream<String> escStream =CG.Keyboard.bindKey('ESCAPE');

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
  readInput(args);
  try {
    console.rawMode = false;
    console.hideCursor();
    Timer.periodic(const Duration(milliseconds: 200), (t) {
      draw(world);
      update(world, gameManager);
      gameManager.tick = DateTime.now();
      if (done) quit();
    });
  } catch (exception) {
    //crash(exception.toString());
    rethrow;
  }
}
