class ReportModel {
  String name;
  int amount;
  double totalServiceFee;
  String date;
  String plate;

  ReportModel({
    required this.name,
    required this.amount,
    required this.totalServiceFee,
    required this.date,
    required this.plate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'totalServiceFee': totalServiceFee,
      'date': date,
      'plate': plate,
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
  return ReportModel(
    name: json['name'] ?? '',
    amount: json['amount'] ?? 0,
    totalServiceFee: json['totalServiceFee']?.toDouble() ?? 0.0,
    date: json['date'] ?? '',
    plate: json['plate'] ?? '',
  );
}

}