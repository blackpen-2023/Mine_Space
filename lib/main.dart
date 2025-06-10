import 'package:flutter/material.dart';
import 'package:mine_space/features/home/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MineSpace());
}

class MineSpace extends StatelessWidget {
  const MineSpace({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: HomePage());
  }
}
