

class Resources{
  String name;
  int quantity;
  Record position;

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