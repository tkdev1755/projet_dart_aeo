

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