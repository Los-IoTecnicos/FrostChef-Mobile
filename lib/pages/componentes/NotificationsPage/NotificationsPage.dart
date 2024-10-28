import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../agregates/api/notification_model.dart';

import '../agregates/dao/NotificationDatabaseHelper.dart';


class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationDatabaseHelper _dbHelper = NotificationDatabaseHelper();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load notifications from the database
      final List<Map<String, dynamic>> notificationsData = await _dbHelper.getNotifications();

      _notifications = notificationsData.map((notification) {
        // Convert string data to Map
        Map<String, dynamic> data = {};
        try {
          String dataStr = notification['data'].toString();
          // Remove the { and } characters from the string
          dataStr = dataStr.substring(1, dataStr.length - 1);

          // Split string into key-value pairs
          List<String> pairs = dataStr.split(',');
          for (String pair in pairs) {
            List<String> keyValue = pair.split(':');
            if (keyValue.length == 2) {
              String key = keyValue[0].trim();
              String value = keyValue[1].trim();
              data[key] = value;
            }
          }
        } catch (e) {
          print('Error al parsear data: $e');
        }

        return NotificationItem(
          id: notification['id'],
          type: notification['type'],
          title: notification['title'],
          message: notification['message'],
          timestamp: DateTime.parse(notification['timestamp']),
          data: data,
        );
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
      setState(() {
        _isLoading = false;
        _notifications = [];
      });
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await _dbHelper.deleteNotification(id);
      setState(() {
        _notifications.removeWhere((notification) => notification.id == id);
      });
    } catch (e) {
      print('Error al eliminar notificación: $e');
    }
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'product':
        icon = Icons.inventory;
        color = Colors.orange;
        break;
      case 'machine':
        icon = Icons.warning;
        color = Colors.red;
        break;
      case 'invitation':
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Dismissible(
      key: Key(notification.id.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                dateFormat.format(notification.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          onTap: () => _showNotificationDetails(notification),
        ),
      ),
    );
  }

  void _showNotificationDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              notification.type == 'product'
                  ? Icons.inventory
                  : notification.type == 'machine'
                  ? Icons.warning
                  : Icons.person_add,
              color: notification.type == 'product'
                  ? Colors.orange
                  : notification.type == 'machine'
                  ? Colors.red
                  : Colors.blue,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.message),
              SizedBox(height: 16),
              if (notification.type == 'product') ...[
                Text('Producto: ${notification.data['name']}'),
                Text('Cantidad: ${notification.data['quantity']}'),
                Text('Fecha de vencimiento: ${notification.data['expirationDate']}'),
              ] else if (notification.type == 'machine') ...[
                Text('Máquina: ${notification.data['machineName']}'),
                Text('Problema: ${notification.data['issue']}'),
                Text('Temperatura: ${notification.data['temperature']}°C'),
              ] else if (notification.type == 'invitation') ...[
                Text('Correo: ${notification.data['email']}'),
                Text('Rol: ${notification.data['role']}'),
                Text('Estado: ${notification.data['status']}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay notificaciones',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationCard(_notifications[index]);
          },
        ),
      ),
    );
  }
}