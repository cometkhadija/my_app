import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(user.photoURL ?? 'https://i.pravatar.cc/300'),
            ),
            SizedBox(height: 30),
            Text(
              'স্বাগতম, ${user.displayName ?? 'বন্ধু'}!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'তুমি এখন বাড়ি থেকে দূরে নও ❤️',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text('লগ আউট'),
            ),
          ],
        ),
      ),
    );
  }
}