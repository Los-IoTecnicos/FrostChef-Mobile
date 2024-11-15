import 'package:flutter/material.dart';
import '../agregates/api/Refrigeration.dart';
import '../agregates/api/RefrigerationService.dart';
import '../agregates/dialog/EquipmentCard.dart';
import '../agregates/dialog/NewEquipmentDialog.dart';

class Equipment extends StatefulWidget {
  @override
  _EquipmentState createState() => _EquipmentState();
}

class _EquipmentState extends State<Equipment> {
  List<Refrigeration> _refrigerationList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRefrigerationList();
  }

  Future<void> _loadRefrigerationList() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final list = await RefrigerationService.getRefrigerationList();

      if (mounted) {
        setState(() {
          _refrigerationList = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }


  void _showNewEquipmentDialog() {
    showDialog(
      context: context,
      builder: (context) => NewEquipmentDialog(
        onSave: (newEquipment) async {
          setState(() {
            _isLoading = true;
          });

          try {
            await _loadRefrigerationList(); // Recargar la lista completa
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_refrigerationList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'There are no equipment items',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _refrigerationList.length,
      itemBuilder: (context, index) {
        return EquipmentCard(equipment: _refrigerationList[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8),
            Text(
              'Refrigeration Equipment',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showNewEquipmentDialog,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add),
          ),

        ],
      ),
    );
  }
}