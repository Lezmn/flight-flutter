import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'flight_ticket.dart';

class FlightBookingPage extends StatefulWidget {
  const FlightBookingPage({super.key});

  @override
  State<FlightBookingPage> createState() => _FlightBookingPageState();
}

class _FlightBookingPageState extends State<FlightBookingPage> {
  String? fromCountry;
  String? toCountry;
  int passengers = 1;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  // ✅ เพิ่มตัวแปรสำหรับ API
  String? Depart;
  String? Arrive;

  // ส่วนลด
  String? selectedDiscount = "ไม่มีส่วนลด";
  final Map<String, double> discounts = const {
    "ไม่มีส่วนลด": 0.0,
    "สมาชิกใหม่ -10%": 0.10,
    "โปรโมชันฤดูร้อน -20%": 0.20,
  };
  

  // ✅ ประเทศ (ให้ตรงกับ HomeScreen)
  final Map<String, int> countries = const {
    "โตเกียว (HND)": 12000,
    "ลอนดอน (LHR)": 18000,
    "ปารีส (CDG)": 15000,
    "โซล (ICN)": 9500,
    "กรุงเทพฯ (BKK)": 3500,
    "นิวยอร์ก (JFK)": 20000,
    "โรม (FCO)": 14000,
  };

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }


  

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0d1b2a), // ✅ ใช้โทนเดียวกับ HomeScreen
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/airplane1.json", fit: BoxFit.cover), // ✅ เปลี่ยนเป็นรูปใน assets
          Container(color: Colors.black.withOpacity(0.6)), // ✅ overlay

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flight_takeoff, size: 80, color: Colors.white),
                        const SizedBox(height: 14),
                        const Text(
                          "ค้นหาและจองเที่ยวบิน",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 20),

                        // ✅ ต้นทาง
                        DropdownButtonFormField<String>(
                          value: fromCountry,
                          dropdownColor: const Color(0xff1b263b),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("ต้นทาง"),
                          items: countries.keys
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: const TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              fromCountry = v;
                              // ตั้งค่า Depart สำหรับ API
                              if (v != null) {
                                Depart = v.split('(')[1].split(')')[0]; // ดึง airport code
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // ✅ ปลายทาง
                        DropdownButtonFormField<String>(
                          value: toCountry,
                          dropdownColor: const Color(0xff1b263b),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("ปลายทาง"),
                          items: countries.keys
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: const TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              toCountry = v;
                              // ตั้งค่า Arrive สำหรับ API
                              if (v != null) {
                                Arrive = v.split('(')[1].split(')')[0]; // ดึง airport code
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 12),

                        // ✅ เลือกวันที่
                        _buildDateTimePicker("เลือกวันที่", _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : "ยังไม่เลือก", Icons.calendar_today, _pickDate),


                        const SizedBox(height: 12),

                        // ✅ ผู้โดยสาร
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("จำนวนผู้โดยสาร", style: TextStyle(color: Colors.white)),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (passengers > 1) setState(() => passengers--);
                                  },
                                  icon: const Icon(Icons.remove_circle, color: Colors.white),
                                ),
                                Text("$passengers", style: const TextStyle(color: Colors.white, fontSize: 16)),
                                IconButton(
                                  onPressed: () => setState(() => passengers++),
                                  icon: const Icon(Icons.add_circle, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ✅ ส่วนลด
                        DropdownButtonFormField<String>(
                          value: selectedDiscount,
                          dropdownColor: const Color(0xff1b263b),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("เลือกส่วนลด"),
                          items: discounts.keys
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: const TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => selectedDiscount = v),
                        ),

                        const SizedBox(height: 18),
                        
                        // ✅ ปุ่มค้นหาเที่ยวบิน
                        ElevatedButton.icon(
                          onPressed: () {
                            // ✅ เพิ่ม validation
                            if (Depart == null || Arrive == null) {
                              showSnackBar('กรุณาเลือกต้นทางและปลายทาง');
                              return;
                            }
                            
                            if (_selectedDate == null) {
                              showSnackBar('กรุณาเลือกวันที่เดินทาง');
                              return;
                            }

                            if (Depart == Arrive) {
                              showSnackBar('ต้นทางและปลายทางต้องไม่เหมือนกัน');
                              return;
                            }

                            // นำทางไปหน้า FlightTicket พร้อมส่งข้อมูล
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: Text('เที่ยวบิน $fromCountry → $toCountry'),
                                    backgroundColor: const Color(0xff0d1b2a),
                                    foregroundColor: Colors.white,
                                  ),
                                  body: FlightTicket(
                                    depart: Depart!,
                                    arrive: Arrive!,
                                    discount: selectedDiscount!,
                                    basePrice: countries[toCountry]!.toDouble() * passengers,
                                    selectedDate: DateFormat('dd/MM/yyyy').format(_selectedDate!),
                                    selectedTime: _selectedTime != null ? _selectedTime!.format(context) : "ยังไม่เลือก",
                                  ),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.search),
                          label: const Text("ค้นหาเที่ยวบิน", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigoAccent),
      ),
    );
  }

  Widget _buildDateTimePicker(String label, String value, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(color: Colors.white)),
          IconButton(onPressed: onTap, icon: Icon(icon, color: Colors.white)),
        ],
      ),
    );
  }
}
