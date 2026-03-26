import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flight_booking_app/ticket.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  // ✅ Map สำหรับแปลงรหัสสนามบินเป็นชื่อเมือง
  final Map<String, String> airportCodeToCity = const {
    "HND": "โตเกียว",
    "LHR": "ลอนดอน",
    "CDG": "ปารีส",
    "ICN": "โซล",
    "BKK": "กรุงเทพฯ",
    "JFK": "นิวยอร์ก",
    "FCO": "โรม",
  };

  // ✅ ฟังก์ชันแปลงรหัสสนามบินเป็นชื่อเมือง
  String getDisplayName(String code) {
    return airportCodeToCity[code] ?? code;
  }

  // ✅ ฟังก์ชันยกเลิกการจอง
  Future<void> cancelBooking(BuildContext context, String bookingId) async {
    try {
      // แสดง dialog ยืนยัน
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ยืนยันการยกเลิก'),
            content: const Text('คุณต้องการยกเลิกการจองนี้หรือไม่?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('ไม่ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ยกเลิก'),
              ),
            ],
          );
        },
      );
      if (confirmed == true) {
        // อัปเดต status ใน Firebase
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .update({'status': 'ยกเลิก'});

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ยกเลิกการจองสำเร็จแล้ว'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("กรุณาเข้าสู่ระบบเพื่อดูประวัติการจอง")),
      );
    }

  

    // ใช้ query แบบง่ายก่อน ไม่ใช้ orderBy เพื่อหลีกเลี่ยงปัญหา index
    final query = FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid);

    return Scaffold(
      backgroundColor: const Color(0xff0d1b2a), // ✅ ใช้โทนเดียวกับ HomeScreen
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snap) {
          print("🔄 StreamBuilder state: ${snap.connectionState}");
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flight_takeoff, color: Colors.grey, size: 64),
                  const SizedBox(height: 16),
                  const Text("ยังไม่มีประวัติการจอง", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    "User ID: ${user.uid}",
                    style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 104, 104, 104)),
                  ),
                ],
              ),
            );
          }


          final docs = snap.data!.docs;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final bookingId = docs[i].id; // ดึง document ID
              final from = getDisplayName(d['from'] ?? '-');
              final to = getDisplayName(d['to'] ?? '-');
              final date = d['date'] ?? '-';
              final time = d['time'] ?? '-';
              final price = (d['price'] ?? 0).toDouble();
              final status = (d['status'] ?? 'รอตรวจสอบ') as String;
              final airline = d['airline'] ?? '-';

              Color border = Colors.grey.shade300;
              Color statusColor = Colors.grey;
              
              if (status.contains("สำเร็จ")) {
                border = Colors.green.shade300;
                statusColor = Colors.green.shade700;
              }
              if (status.contains("ยกเลิก")) {
                border = Colors.red.shade300;
                statusColor = Colors.red.shade700;
              }
              if (status.contains("รอตรวจสอบ")) {
                border = Colors.orange.shade300;
                statusColor = Colors.orange.shade700;
              }

              // ตรวจสอบว่าสามารถยกเลิกได้หรือไม่
              final canCancel = !status.contains("ยกเลิก") && !status.contains("สำเร็จ");

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          "สายการบิน: $airline    ",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          "จาก $from  ไป $to\nวันที่ $date   เวลา: $time\nราคา: ${NumberFormat('#,###').format(price)} บาท",
                        ),
                      ),
                      if (canCancel) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => cancelBooking(context, bookingId),
                            child: const Text('ยกเลิกการจอง'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
