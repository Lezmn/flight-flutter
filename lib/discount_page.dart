import 'package:flutter/material.dart';

class DiscountPage extends StatelessWidget {
  const DiscountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final discounts = [
      {"title": "สมาชิกใหม่ ลด 10%", "desc": "ใช้ได้กับทุกเส้นทาง"},
      {"title": "โปรโมชันฤดูร้อน ลด 20%", "desc": "เฉพาะญี่ปุ่นและเกาหลี"},
      {"title": "บินคู่ ลด 15%", "desc": "เมื่อจองพร้อมกัน 2 ที่นั่ง"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("ส่วนลดที่มี")),
      body: ListView.builder(
        itemCount: discounts.length,
        itemBuilder: (_, i) {
          final d = discounts[i];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(d["title"]!),
              subtitle: Text(d["desc"]!),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("เลือก: ${d["title"]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
