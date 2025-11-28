// lib/utils/constants.dart

import 'package:flutter/material.dart';

const List<Map<String, dynamic>> categories = [
  {
    "name": "Food",
    "icon": Icons.fastfood,
    "color": Color(0xFF8B0000), // Dark Wine
  },
  {
    "name": "Transportation",
    "icon": Icons.directions_bus,
    "color": Color(0xFFB22222), // Firebrick
  },
  {
    "name": "Shopping",
    "icon": Icons.shopping_bag,
    "color": Color(0xFFDC143C), // Crimson
  },
  {
    "name": "Education",
    "icon": Icons.school,
    "color": Color(0xFFC71585), // Medium Violet Red
  },
  {
    "name": "Health",
    "icon": Icons.local_hospital,
    "color": Color(0xFFDB7093), // Pale Violet Red
  },
  {
    "name": "Donation",
    "icon": Icons.volunteer_activism,
    "color": Color(0xFFFF1493), // Deep Pink
  },
  {
    "name": "Entertainment",
    "icon": Icons.movie,
    "color": Color(0xFFFF69B4), // Hot Pink (Light)
  },
  {
    "name": "Others",
    "icon": Icons.more_horiz,
    "color": Color(0xFFA52A2A), // Brown (Deep Wine shade)
  },
];

// তোমার পুরো অ্যাপের জন্য প্রিমিয়াম নেভি + সিলভার থিম
const Color primaryNavy = Color(0xFF1A237E);     // Deep Navy (AppBar, Buttons)
const Color navyLight = Color(0xFF3F51B5);       // Lighter Navy
const Color silverGray = Color(0xFFB0BEC5);      // Text / Icons
const Color backgroundGray = Color(0xFFF5F7FA);  // Page Background
const Color cardWhite = Color(0xFFFFFFFF);       // Cards
const Color accentWine = Color(0xFF8B0000);      // Highlight / FAB

// যদি কোথাও পুরানো primaryColor/accentColor ব্যবহার করে থাকো, তাহলে এগুলো দিয়ে রিপ্লেস করো