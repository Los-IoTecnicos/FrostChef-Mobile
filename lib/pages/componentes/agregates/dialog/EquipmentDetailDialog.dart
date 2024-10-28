import 'package:flutter/material.dart';

import '../api/Refrigeration.dart';
import '../dao/NotificationDatabaseHelper.dart';

class EquipmentDetailDialog extends StatelessWidget {
  final Refrigeration equipment;

  const EquipmentDetailDialog({Key? key, required this.equipment}) : super(key: key);

  Future<void> createMachineNotification(Map<String, dynamic> machine, String issue) async {
    final dbHelper = NotificationDatabaseHelper();

    await dbHelper.insertNotification({
      'type': 'machine',
      'title': 'Alerta de máquina',
      'message': 'Se detectó un problema en ${machine['name']}: $issue',
      'timestamp': DateTime.now().toIso8601String(),
      'data': {
        'machineName': machine['name'],
        'issue': issue,
        'temperature': machine['temperature'],
      }.toString(),
    });
  }
  void _showReportDialog(BuildContext context) {
    final TextEditingController issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enviar Reporte de Máquina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Por favor, describe el problema:'),
              SizedBox(height: 10),
              TextField(
                controller: issueController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe el problema aquí...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (issueController.text.isNotEmpty) {
                  // Create the machine map with the necessary data
                  final machineData = {
                    'name': equipment.title,
                    'temperature': equipment.temperature,
                  };

                  // Create the notification
                  await createMachineNotification(machineData, issueController.text);

                  // Close the dialogues
                  Navigator.pop(context); // Close the report dialog
                  Navigator.pop(context); // Close the details dialog

                  // Show confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reporte enviado con éxito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Enviar Reporte'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  equipment.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            _buildDetailRow('Modelo', equipment.model),
            _buildDetailRow('Número de Serie', equipment.serialNumber),
            _buildDetailRow('Temperatura', equipment.temperature),
            _buildDetailRow('Humedad', equipment.humidity),
            _buildDetailRow('Último Mantenimiento', equipment.lastMaintenance),
            _buildDetailRow('Próximo Mantenimiento', equipment.nextMaintenance),
            _buildDetailRow('Fecha de Instalación', equipment.installedDate),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showReportDialog(context),
                  icon: Icon(Icons.report_problem),
                  label: Text('Enviar Reporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}