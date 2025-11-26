import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/auth/login_screen.dart';
import 'web/firebase_config.dart'; // lib/web/firebase_config.dart theke

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 👇 Web vs Mobile alada handle
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: webFirebaseOptions, // web er config
    );
  } else {
    await Firebase.initializeApp(); // android/ios er jonno (google-services.json use korbe)
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bari Theke Dure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// ৫টা ট্যাবের মেইন স্ক্রিন
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const Center(child: Text("Home", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
    const Center(child: Text("Mood Tracker", style: TextStyle(fontSize: 45))),
    const Center(child: Text("Expenses", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
    const Center(child: Text("Grooming", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
    const Center(child: Text("Profile", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: "Mood"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Expenses"),
          BottomNavigationBarItem(icon: Icon(Icons.face_retouching_natural), label: "Grooming"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}


