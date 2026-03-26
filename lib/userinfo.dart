

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'sign_in_page.dart';
import 'home_page.dart';


class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers สำหรับ form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  

  bool _isLoading = false;
  bool _isEditing = false;

  // รายชื่อประเทศ
  final List<String> _countries = [
    'ไทย', 'สหรัฐอเมริกา', 'สหราชอาณาจักร', 'ญี่ปุ่น', 'เกาหลีใต้',
    'จีน', 'ฝรั่งเศส', 'เยอรมนี', 'อิตาลี', 'สเปน', 'แคนาดา', 'ออสเตรเลีย',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // โหลดข้อมูลผู้ใช้จาก Firestore
  Future<void> _loadUserData() async {
    if (user == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
          
      if (doc.exists) {
        final data = doc.data()!;
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _countryController.text = data['country'] ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // บันทึกข้อมูลลง Firestore
  Future<void> _saveUserData() async {
    if (user == null || !_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'country': _countryController.text.trim(),
        'email': user!.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      setState(() => _isEditing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึก: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('กรุณาเข้าสู่ระบบ')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffe9f2ff),
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        backgroundColor: const Color(0xff1b263b),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Email (อ่านอย่างเดียว)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.email, color: Colors.blue),
                        title: const Text('อีเมล'),
                        subtitle: Text(user!.email ?? 'ไม่มีข้อมูล'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ชื่อ
                    TextFormField(
                      controller: _firstNameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อ',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isEditing && (value == null || value.trim().isEmpty)) {
                          return 'กรุณากรอกชื่อ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // นามสกุล
                    TextFormField(
                      controller: _lastNameController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        labelText: 'นามสกุล',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isEditing && (value == null || value.trim().isEmpty)) {
                          return 'กรุณากรอกนามสกุล';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ประเทศ
                    DropdownButtonFormField<String>(
                      value: _countries.contains(_countryController.text) 
                          ? _countryController.text 
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'ประเทศที่อยู่',
                        prefixIcon: Icon(Icons.flag),
                        border: OutlineInputBorder(),
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      onChanged: _isEditing ? (value) {
                        _countryController.text = value ?? '';
                      } : null,
                      validator: (value) {
                        if (_isEditing && (value == null || value.isEmpty)) {
                          return 'กรุณาเลือกประเทศ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // ปุ่มบันทึก/ยกเลิก
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() => _isEditing = false);
                                _loadUserData(); // โหลดข้อมูลเดิมกลับมา
                              },
                              child: const Text('ยกเลิก'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveUserData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('บันทึก'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ปุ่มกลับหน้าหลัก
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.home),
                      label: const Text('กลับหน้าหลัก'),
                    ),
                    const SizedBox(height: 12),

                    // ปุ่มออกจากระบบ
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('ออกจากระบบ'),
                    ),
                  ],
                ),
              ),
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