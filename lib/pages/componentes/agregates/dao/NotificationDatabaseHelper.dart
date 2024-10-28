import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDatabaseHelper {
  static final NotificationDatabaseHelper _instance = NotificationDatabaseHelper._internal();
  factory NotificationDatabaseHelper() => _instance;

  static Database? _database;

  NotificationDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notifications.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notifications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            data TEXT NOT NULL,
            isRead INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // Insert a new notification
  Future<int> insertNotification(Map<String, dynamic> notification) async {
    final db = await database;
    // Convertimos el campo data a STRING ya que SQLite no admite JSON directamente
    notification['data'] = notification['data'].toString();
    return await db.insert('notifications', notification);
  }

  // Get all notifications sorted by date
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
    );
  }

  // Get notifications by type
  Future<List<Map<String, dynamic>>> getNotificationsByType(String type) async {
    final db = await database;
    return await db.query(
      'notifications',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'timestamp DESC',
    );
  }

  // Delete a notification
  Future<int> deleteNotification(int id) async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark a notification as read
  Future<int> markAsRead(int id) async {
    final db = await database;
    return await db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE isRead = 0'
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Delete all notifications
  Future<int> deleteAllNotifications() async {
    final db = await database;
    return await db.delete('notifications');
  }

  // Delete old notifications (older than 30 days)
  Future<int> deleteOldNotifications() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30)).toIso8601String();
    return await db.delete(
      'notifications',
      where: 'timestamp < ?',
      whereArgs: [thirtyDaysAgo],
    );
  }
}