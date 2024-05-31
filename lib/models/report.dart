class ReportModel {
  String name;
  double total_amount;
  double totalServiceFee;
  int no_of_ticket;
  String date;
  String plate;
  String level;

  ReportModel({
    required this.name,
    required this.total_amount,
    required this.totalServiceFee,
    required this.no_of_ticket,
    required this.date,
    required this.plate,
    required this.level
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'total_amount': total_amount,
      'totalServiceFee': totalServiceFee,
      'no_of_ticket':no_of_ticket,
      'date': date,
      'plate': plate,
      'level': level
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      name: json['name'] ?? '',
      total_amount: json['total_amount'] ?? 0.0,
      totalServiceFee: json['totalServiceFee'] ?? 0.0,
      no_of_ticket: json['no_of_ticket'] ?? 0,
      date: json['date'] ?? '',
      plate: json['plate'] ?? '',
      level: json['level'] ?? ''
    );
  }
}