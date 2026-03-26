import 'package:flutter/material.dart';

class PromotionPage extends StatelessWidget {
  const PromotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final promos = [
      {"title": "Summer Sale ✈️", "desc": "ลดสูงสุด 30%"},
      {"title": "Midnight Deal 🌙", "desc": "จองหลังเที่ยงคืนลดทันที 500฿"},
      {"title": "Weekend Flight 🛫", "desc": "ลด 15% ทุกเส้นทางเสาร์-อาทิตย์"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("โปรโมชั่น")),
      body: ListView.builder(
        itemCount: promos.length,
        itemBuilder: (_, i) {
          final p = promos[i];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(p["title"]!),
              subtitle: Text(p["desc"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("เลือก: ${p["title"]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
