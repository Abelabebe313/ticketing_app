import 'package:sqflite/sqflite.dart';
import 'package:transport_app/data/db_helper.dart';
import 'package:transport_app/models/report.dart';

class ReportLocalDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> setReport(ReportModel report) async {
    print('report saving...');
    final db = await _databaseHelper.database;
    await db.insert('report', report.toJson());
    print('report added successfully');
  }


  Future<List<ReportModel>> getAllReport() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('report');
    return List.generate(maps.length, (i) {
      return ReportModel.fromJson(maps[i]);
    });
  }

  Future<void> clearReports() async {
    final db = await _databaseHelper.database;
    await db.delete('report');
    print('All reports cleared successfully');
  }
}
