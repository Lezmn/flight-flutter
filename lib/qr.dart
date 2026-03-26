import 'dart:ui';
import 'package:flight_booking_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ticket.dart';



// 🔥 สร้าง QR PromptPay
void showPromptPayQR(BuildContext context, Data flightData, String departCode, String arriveCode,  {
  String? fromCountry,
  String? toCountry, 
  int passengers = 1,
  String? selectedDate,
  String? selectedTime,
  String? selectedDiscount = "ไม่มีส่วนลด",
  double? finalPrice,
}) {
  const String promptPayID = "1102003697141"; // เลขประจำตัวประชาชน หรือ เบอร์โทร
  final double amount = finalPrice ?? 17500.0; // ราคาเที่ยวบิน
  
  final String qrData = _generatePromptPayQR(promptPayID, amount);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff0d1b2a), Color(0xff1b263b)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.qr_code, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '💳 ชำระเงินผ่าน PromptPay',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Flight Info Summary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'เที่ยวบิน: ${flightData.flight?.iata ?? 'N/A'}',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${flightData.departure?.iata ?? departCode} → ${flightData.arrival?.iata ?? arriveCode}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          Text(
                            '₿ ${NumberFormat('#,###').format(amount)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // QR Code พร้อม Debug Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            errorCorrectionLevel: QrErrorCorrectLevel.M,
                          ),
                          const SizedBox(height: 8),
                          // Debug Info
                          Text(
                            'QR Length: ${qrData.length} chars',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context); // ปิด QR dialog
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('ยกเลิก'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                               // จำลองการรอ
                              // แสดง loading SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar (
                                  content: Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('กำลังบันทึกการจอง...'),
                                      
                                    ],
                                  ),
                                  backgroundColor: Colors.blue,
                                  duration: Duration(seconds: 5),
                                ),
                              );
                              
                              
                              // บันทึกข้อมูลลง Firebase
                              await _bookFlight(
                                context: context,
                                flightData: flightData,
                                departCode: departCode,
                                arriveCode: arriveCode,
                                fromCountry: fromCountry,
                                toCountry: toCountry,
                                passengers: passengers,
                                selectedDate: selectedDate,
                                selectedTime: selectedTime,
                                selectedDiscount: selectedDiscount,
                                finalPrice: finalPrice ?? amount,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('ยืนยันการจอง'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
// � บันทึกข้อมูลการจอง Firebase
Future<void> _bookFlight({
  required BuildContext context,
  required Data flightData,
  required String departCode,
  required String arriveCode,
  String? fromCountry,
  String? toCountry,
  int passengers = 1,
  String? selectedDate,
  String? selectedTime,
  String? selectedDiscount,
  double? finalPrice,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  print("🔍 ตรวจสอบ user: ${user?.email ?? 'ไม่มีผู้ใช้'}");
  
  if (user == null) {
    print("❌ ผู้ใช้ยังไม่ได้เข้าสู่ระบบ");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณาเข้าสู่ระบบก่อนทำการจอง"),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }
    // สร้างข้อมูลการจอง
    try {
      await FirebaseFirestore.instance.collection("bookings").add({
       "userId": user.uid,
      "userEmail": user.email,
      "flightNumber": flightData.flight?.iata ?? "N/A",
      "airline": flightData.airline?.name ?? "N/A",
      "from": fromCountry ?? departCode,
      "to": toCountry ?? arriveCode,
      "departCode": departCode,
      "arriveCode": arriveCode,
      "date": selectedDate ?? "ไม่ระบุ",
      "time": selectedTime ?? "ไม่ระบุ",
      "passengers": passengers,
      "discount": selectedDiscount ?? "ไม่มีส่วนลด",
      "price": finalPrice ?? 17500.0,
      "status": "รอตรวจสอบ",
      "paymentMethod": "PromptPay QR",
      "createdAt": FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        // กลับไปหน้าค้นหาตั๋ว
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("จองตั๋วสำเร็จ! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
        );
      }
    }
    
}

// ��� สร้าง PromptPay QR Code String 
String _generatePromptPayQR(String promptPayID, double amount) {
  String qrString = '';
  
  // 00: Payload Format Indicator
  qrString += '000201';
  
  // 01: Point of Initiation Method
  qrString += '010211';
  
  // 29: Merchant Account Information (PromptPay)
  String merchantInfo = '';
  merchantInfo += '0016'; // Tag 00: GUI
  merchantInfo += 'A000000677010111'; // PromptPay GUID
  merchantInfo += '02${promptPayID.length.toString().padLeft(2, '0')}$promptPayID'; // Tag 02: Phone/ID
  
  qrString += '29${merchantInfo.length.toString().padLeft(2, '0')}$merchantInfo';
  
  // 53: Transaction Currency (764 = THB)
  qrString += '5303764';
  
  // 54: Transaction Amount
  String amountStr = amount.toStringAsFixed(2);
  qrString += '54${amountStr.length.toString().padLeft(2, '0')}$amountStr';
  
  // 58: Country Code
  qrString += '5802TH';
  
  // 59: Merchant Name
  String merchantName = 'FLIGHT BOOKING APP';
  qrString += '59${merchantName.length.toString().padLeft(2, '0')}$merchantName';
  
  // 60: Merchant City  
  String merchantCity = 'BANGKOK';
  qrString += '60${merchantCity.length.toString().padLeft(2, '0')}$merchantCity';
  
  // 62: Additional Data Field Template
  String additionalData = '0503***'; // Bill Number
  qrString += '62${additionalData.length.toString().padLeft(2, '0')}$additionalData';
  
  // 63: CRC16 (คำนวณ CRC16)
  qrString += '6304';
  String crc = _calculateCRC16(qrString);
  qrString += crc;
  
  return qrString;
}

// 🔧 คำนวณ CRC16 สำหรับ PromptPay
String _calculateCRC16(String data) {
  int crc = 0xFFFF;
  const int polynomial = 0x1021;
  
  for (int i = 0; i < data.length; i++) {
    crc ^= data.codeUnitAt(i) << 8;
    
    for (int j = 0; j < 8; j++) {
      if ((crc & 0x8000) != 0) {
        crc = (crc << 1) ^ polynomial;
      } else {
        crc <<= 1;
      }
      crc &= 0xFFFF;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}
