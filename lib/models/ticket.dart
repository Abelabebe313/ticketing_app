class Ticket {
  String tailure;
  String level;
  String plate;
  DateTime date;
  String destination;
  String departure;
  int uniqueId;
  double tariff;
  double charge;
  String association;
  String distance;

  Ticket({
    required this.tailure,
    required this.level,
    required this.plate,
    required this.date,
    required this.destination,
    required this.departure,
    required this.uniqueId,
    required this.tariff,
    required this.charge,
    required this.association,
    required this.distance,
  });
  Map<String, dynamic> toJson() {
    return {
      'tailure': tailure,
      'lastName': level,
      'plate': plate,
      'date': date.toIso8601String(),
      'destination': destination,
      'departure': departure,
      'uniqueId': uniqueId,
      'tariff': tariff,
      'charge': charge,
      'association': association,
      'distance': distance,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      tailure: json['tailure'] ?? '',
      level: json['level'] ?? '',
      plate: json['plate'] ?? '',
      date: DateTime.parse(json['date'] ?? ''),
      destination: json['destination'] ?? '',
      departure: json['departure'] ?? '',
      uniqueId: json['uniqueId'] ?? 0,
      tariff: json['tariff'] ?? 0.0,
      charge: json['charge'] ?? 0.0,
      association: json['association'] ?? '',
      distance: json['distance'] ?? '',
    );
  }
}