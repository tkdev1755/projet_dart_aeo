

class Resources{
  String name;
  int quantity;
  (int,int) position;
  Resources(
      this.name,
      this.quantity,
      this.position
      );

  @override
  String toString() {
    return name;
  }
}

class Wood extends Resources{

  Wood(
      (int,int) position,
      ) : super("w",100,position,);

}

class Gold extends Resources{

  Gold(
      (int,int) position,
      ) : super("g",100,position,);
}

class Food extends Resources{

  Food(
      (int,int) position,
      ) : super("f",100,position,);
}
