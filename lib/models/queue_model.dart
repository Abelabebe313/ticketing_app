class QueueModel {
  String station;
  String plateNumber;
  String date;
  String time;
  String association;

  QueueModel({
    required this.station,
    required this.plateNumber,
    required this.date,
    required this.time,
    required this.association,
  });

  Map<String, dynamic> toJson() {
    return {
      'station': station,
      'plateNumber': plateNumber,
      'date': date,
      'time': time,
      'association': association,
    };
  }

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      station: json['station'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      date: json['date'].toString(),
      time: json['time'] ?? '',
      association: json['association'] ?? '',
    );
  }
}