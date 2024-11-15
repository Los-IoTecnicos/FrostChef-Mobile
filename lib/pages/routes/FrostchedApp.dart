import 'package:flutter/material.dart';
import 'package:frostchef/pages/routes/principal/HomeScreen.dart';
import '../componentes/ProfileScreen/ProfileScreen.dart';
import '../componentes/InventoriesPage/InventoriesPage.dart';
import '../componentes/MenuPage/MenuPage.dart';
import '../componentes/NotificationsPage/NotificationsPage.dart';
import '../componentes/TeamPage/Equipment.dart';
import '../models/login/LoginScreen.dart';
import '../models/login/RegisterScreen.dart';


class FrostchedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home', // Ruta inicial
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/menu': (context) => MenuPage(),
        '/team': (context) => Equipment(),
        '/inventory': (context) => InventoriesPage(),
        '/notifications': (context) => NotificationsPage(),
        '/profile': (context) => ProfileScreen(),

      },
    );
  }
}




