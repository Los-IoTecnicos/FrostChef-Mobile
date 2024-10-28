import 'package:flutter/material.dart';

import '../agregates/api/Refrigeration.dart';
import '../agregates/api/RefrigerationService.dart';
import '../agregates/dialog/EquipmentCard.dart';

class Equipment extends StatelessWidget {
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
      body: FutureBuilder<List<Refrigeration>>(
        future: RefrigerationService.getRefrigerationList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error loading equipment',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'There are no teams available',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return EquipmentCard(equipment: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}