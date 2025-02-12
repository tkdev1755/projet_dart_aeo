

class TerminalController{

  bool debug;
  bool showRes;
  bool pause;
  bool running;
  bool quit;


  TerminalController(
      this.debug,
      this.showRes,
      this.pause,
      this.running,
      this.quit
      );

  void pauseGame(){
    pause = !pause;
    running = !running;
  }

}