class Ticket {
  String tailure;
  String level;
  String plate;
  DateTime date;
  String destination;
  String departure;
  String uniqueId;
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
      'level': level,
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
      date: json['date'] is String ? DateTime.parse(json['date']) : DateTime.now(),
      destination: json['destination'] ?? '',
      departure: json['departure'] ?? '',
      uniqueId: json['uniqueId'] ?? '',
      tariff: (json['tariff'] is num) ? json['tariff'].toDouble() : 0.0,
      charge: (json['charge'] is num) ? json['charge'].toDouble() : 0.0,
      association: json['association'] ?? '',
      distance: json['distance'] ?? '',
    );
  }
}