class Location {
  final String origin;
  final String destination;

  Location({
    required this.origin,
    required this.destination,
  });

  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      origin: json['origin'],
      destination: json['destination'],
    );
  }


}