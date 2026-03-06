import 'package:flutter/material.dart';
import 'features/register/page/register_temp_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Runway', home: RegisterTempScreen());
  }
}
