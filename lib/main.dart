import 'package:flutter/material.dart';
import 'package:frostchef/pages/models/login/providers/AuthProvider.dart';
import 'package:frostchef/pages/routes/FrostchedApp.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: FrostchedApp(),
    ),
  );
}