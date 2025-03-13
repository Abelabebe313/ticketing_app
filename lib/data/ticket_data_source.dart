import 'package:sqflite/sqflite.dart';
import 'package:transport_app/data/db_helper.dart';
import 'package:transport_app/models/ticket.dart';

class TicketDataSource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Save a ticket to the database
  Future<int> saveTicket(Ticket ticket) async {
    final db = await _databaseHelper.database;
    final ticketMap = ticket.toJson();
    
    // Add date in string format if it's a DateTime object
    if (ticket.date is DateTime) {
      ticketMap['date'] = ticket.date.toIso8601String();
    }
    // Default is_uploaded to 0 (not uploaded)
    ticketMap['is_uploaded'] = 0;
    
    print('Saving ticket: $ticketMap');
    return await db.insert('tickets', ticketMap);
  }

  // Get all tickets from the database
  Future<List<Ticket>> getAllTickets() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('tickets');
    return List.generate(maps.length, (i) {
      return Ticket.fromJson(maps[i]);
    });
  }

  // Get tickets that haven't been uploaded yet
  Future<List<Ticket>> getUnuploadedTickets() async {
    try {
      final db = await _databaseHelper.database;
      print('Looking for unuploaded tickets in database...');
      final List<Map<String, dynamic>> maps = await db.query(
        'tickets',
        where: 'is_uploaded = ?',
        whereArgs: [0],
      );
      print('Found ${maps.length} unuploaded tickets in database');
      for (var map in maps) {
        print('Ticket data: $map');
      }
      
      return List.generate(maps.length, (i) {
        return Ticket.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error getting unuploaded tickets: $e');
      return [];
    }
  }

  // Mark tickets as uploaded
  Future<int> markTicketsAsUploaded(List<String> uniqueIds) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'tickets',
      {'is_uploaded': 1},
      where: 'uniqueId IN (${List.filled(uniqueIds.length, '?').join(', ')})',
      whereArgs: uniqueIds,
    );
  }

  // Delete uploaded tickets
  Future<int> deleteUploadedTickets() async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'tickets',
      where: 'is_uploaded = ?',
      whereArgs: [1],
    );
  }

  // Get ticket count
  Future<int> getTicketCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM tickets');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get unuploaded ticket count
  Future<int> getUnuploadedTicketCount() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM tickets WHERE is_uploaded = 0',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
