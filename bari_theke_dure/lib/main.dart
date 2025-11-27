import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // CLI-generated


import 'screens/auth/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow; // অন্য কোনো error হলে crash করবে
    }
    // duplicate-app হলে ignore করবে
  }

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // এই লাইনটা যোগ কর — এটাই ম্যাজিক
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            return const MainScreen();           // লগইন হলে সরাসরি হোম
          } else {
            return const LoginScreen();          // লগআউট থাকলে লগইন স্ক্রিন
          }
        }

        // লোডিং এর সময় সার্কুলার দেখাবে
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int i = 0;
  final pages = [
    const Center(child: Text("Home", style: TextStyle(fontSize: 60))),
    const Center(child: Text("Mood", style: TextStyle(fontSize: 60))),
    const Center(child: Text("Expenses", style: TextStyle(fontSize: 60))),
    const Center(child: Text("Grooming", style: TextStyle(fontSize: 60))),
    const Center(child: Text("Profile", style: TextStyle(fontSize: 60))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[i],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: i,
        selectedItemColor: Colors.deepPurple,
        onTap: (x) => setState(() => i = x),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: "Mood"),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: "Expenses"),
          BottomNavigationBarItem(icon: Icon(Icons.face), label: "Grooming"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
