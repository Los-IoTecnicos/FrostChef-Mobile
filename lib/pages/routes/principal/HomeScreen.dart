import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../componentes/CollaboratorsPage/CollaboratorsPage.dart';
import '../../componentes/InventoriesPage/InventoriesPage.dart';
import '../../componentes/MenuPage/MenuPage.dart';
import '../../componentes/NotificationsPage/NotificationsPage.dart';
import '../../componentes/TeamPage/Equipment.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Índice de la pestaña seleccionada
  DateTime? _lastBackPressTime; // Tiempo del último toque

  final List<Widget> _pages = [
    MenuPage(),
    Equipment(),
    InventoriesPage(),
    NotificationsPage(),
    CollaboratorsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Interceptar el botón de retroceso
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Frostched',
            style: GoogleFonts.pacifico(
              textStyle: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: [
            _buildBottomNavigationBarItem(Icons.home, 'Menú', 0),
            _buildBottomNavigationBarItem(Icons.group, 'Equipo', 1),
            _buildBottomNavigationBarItem(Icons.inventory, 'Inventarios', 2),
            _buildBottomNavigationBarItem(Icons.notifications, 'Notificaciones', 3),
            _buildBottomNavigationBarItem(Icons.people, 'Técnicos', 4),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white, // Fondo de la barra de navegación
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    // Si no hay tiempo registrado, configura el tiempo actual
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > Duration(seconds: 1)) {
      // Configura el tiempo del último toque
      _lastBackPressTime = now;

      // Vibrar y mostrar el Toast
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100); // Vibra durante 100 ms
      }
      Fluttertoast.showToast(
        msg: "Presiona nuevamente para salir",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey.shade900,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return false; // No cerrar la aplicación
    }

    return true; // Cierra la aplicación
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.rectangle, // Cambiar a rectángulo para el fondo
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 28,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      label: '',
    );
  }
}
