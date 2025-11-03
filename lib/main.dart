import 'package:flutter/material.dart';
import 'package:certiweb_flutter_application/certifications/components/reservation/reservation_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CertiWeb',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ReservationPage(),
    );
  }
}
