class RestaurantFloor {
  const RestaurantFloor({
    required this.id,
    required this.name,
    required this.posConfigIds,
  });

  final int id;
  final String name;
  final List<int> posConfigIds;
}

class RestaurantTable {
  const RestaurantTable({
    required this.id,
    required this.number,
    required this.floorId,
    required this.floorName,
    required this.active,
    this.seats,
  });

  final int id;
  final int number;
  final int floorId;
  final String floorName;
  final bool active;
  final int? seats;

  String get label => '$floorName · Mesa $number';
}
