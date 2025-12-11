import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 💥 FULL immersive mode (fixes black bars in landscape)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Optional, still transparent status/navigation bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeNav(),
    );
  }
}
