/// The above Dart code defines a Flutter app with a MaterialApp that sets up a Discovery App with a
/// primary color theme and a home page of DiscoveryPage.
import 'package:flutter/material.dart';

import 'package:together/discover_page.dart';

void main() {
  runApp(const MyApp());
}

/// The `MyApp` class is a StatelessWidget representing the main application widget in a Flutter app
/// with a title, theme, and home page set to `DiscoveryPage`.

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Discovery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DiscoveryPage(),
    );
  }
}
