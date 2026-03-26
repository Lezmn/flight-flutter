import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'flight_search_page.dart';
import 'my_bookings_page.dart';
import 'sign_in_page.dart';
import 'userinfo.dart';
import 'Discount.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    FlightBookingPage(),
    MyBookingsPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        indicatorColor: Colors.indigo.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.indigo),
            label: "หน้าหลัก",
          ),
          NavigationDestination(
            icon: Icon(Icons.flight_takeoff_outlined),
            selectedIcon: Icon(Icons.flight_takeoff, color: Colors.indigo),
            label: "จองเที่ยวบิน",
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: Colors.indigo),
            label: "ประวัติการจอง",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.indigo),
            label: "บัญชี",
          ),
        ],
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xffe9f2ff),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? "ไม่ทราบอีเมล",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.indigo),
                  title: const Text("ข้อมูลบัญชี"),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const UserInfoPage()),
                      );
                  },
                ),
                const Divider(height: 0),

                ListTile(
                  leading: const Icon(Icons.discount, color: Colors.indigo),
                  title: const Text("ส่วนลดที่มี"),
                  onTap: () {
                    showPromotionDialog(context);
                  },
                ),
                const Divider(height: 0),

                // ✅ เกี่ยวกับเรา -> Popup UI Box
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.indigo),
                  title: const Text("เกี่ยวกับเรา"),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text("เกี่ยวกับเรา", style: TextStyle(fontWeight: FontWeight.bold)),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView(
                              shrinkWrap: true,
                              children: const [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.indigo,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text("ฝ่ายออกแบบ UI/UX"),
                                  subtitle: Text("คุณาวุฒิ ดอกบัว"),
                                ),
                                Divider(),
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text("ธนบดี ประดับคำ"),
                                  subtitle: Text("ผู้พัฒนาแอปพลิเคชัน"),
                                ),
                                Divider(),
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange,
                                    child: Icon(Icons.person, color: Colors.white),
                                  ),
                                  title: Text("ฝ่ายออกแบบ UI/UX"),
                                  subtitle: Text("นนทกร"),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text("ปิด", style: TextStyle(color: Colors.indigo)),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 0),
                const SizedBox(height: 8),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("ออกจากระบบ"),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
