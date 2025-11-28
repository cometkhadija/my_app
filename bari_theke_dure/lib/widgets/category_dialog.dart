import 'package:flutter/material.dart';
import '../utils/constants.dart';

void showCategoryDialog(BuildContext context, Function(String, double) onAdd) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) => GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            final controller = TextEditingController();
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(cat['name']),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "টাকার পরিমাণ"),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text("বাতিল")),
                  ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(controller.text) ?? 0;
                      if (amount > 0) onAdd(cat['name'], amount);
                      Navigator.pop(context);
                    },
                    child: const Text("যোগ করুন"),
                  ),
                ],
              ),
            );
          },
          child: Column(
            children: [
              CircleAvatar(radius: 30, backgroundColor: cat['color'], child: Icon(cat['icon'], size: 30, color: Colors.white)),
              const SizedBox(height: 8),
              Text(cat['name'], style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    ),
  );
}