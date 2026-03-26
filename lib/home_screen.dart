import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import หน้าอื่น
import 'country_detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  final PageController _placesController = PageController(viewportFraction: 0.85);

  Timer? _autoSlideTimer;

  // ✅ Banner images
  final bannerImages = [
    "assets/Tokyo.jpg",
    "assets/london1.jpg",
    "assets/paris.jpg",
    "assets/seoul.jpg",
    "assets/bangkok.jpg",
    "assets/newyork.jpg",
    "assets/rome.jpg",
  ];

  // ✅ Place images + extra images
  final places = [
    {
      "name": "โตเกียว",
      "img": "assets/tokyo2.jpg",
      "extra": ["assets/Tokyo.jpg", "assets/tokyo2.jpg"]
    },
    {
      "name": "ลอนดอน",
      "img": "assets/london2.jpg",
      "extra": ["assets/london1.jpg", "assets/london2.jpg"]
    },
    {
      "name": "ปารีส",
      "img": "assets/paris2.jpg",
      "extra": ["assets/paris.jpg", "assets/paris2.jpg"]
    },
    {
      "name": "โซล",
      "img": "assets/seoul2.jpg",
      "extra": ["assets/seoul.jpg", "assets/seoul2.jpg"]
    },
    {
      "name": "กรุงเทพฯ",
      "img": "assets/bangkok2.jpg",
      "extra": ["assets/bangkok.jpg", "assets/bangkok2.jpg"]
    },
    {
      "name": "นิวยอร์ก",
      "img": "assets/newyork2.jpg",
      "extra": ["assets/newyork.jpg", "assets/newyork2.jpg"]
    },
    {
      "name": "โรม",
      "img": "assets/rome2.jpg",
      "extra": ["assets/rome.jpg", "assets/rome2.jpg"]
    },
  ];

  @override
  void initState() {
    super.initState();

    // ✅ Auto slide
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_placesController.hasClients) {
        int nextPage = _placesController.page!.round() + 1;
        if (nextPage == places.length) {
          nextPage = 0;
        }
        _placesController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _placesController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xff0d1b2a),
      appBar: AppBar(
        backgroundColor: const Color(0xff1b263b),
        leading: const Icon(Icons.cast, color: Colors.white),
        title: Text(
          "Flight Booking (${user?.email ?? 'Guest'})",
          style: const TextStyle(color: Colors.white),
        ),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(end: 16.0),
            child: CircleAvatar(child: Icon(Icons.account_circle)),
          ),
        ],
      ),
      body: ListView(
        children: [
          // ✅ Hero Banner
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _bannerController,
              itemCount: bannerImages.length,
              itemBuilder: (_, i) {
                return HeroLayoutCard(
                  title: "โปรโมชั่น",
                  subtitle: "ดีลพิเศษสำหรับคุณ",
                  imagePath: bannerImages[i],
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          // 🔹 หัวข้อโค้ดส่วนลด
          _SectionHeader(title: "โค้ดส่วนลด"),

          // 🔹 การ์ดแบนเนอร์ (เลื่อนได้ + รูปเต็มกรอบ)
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _PromoBannerCard(
                  imagePath: "assets/discount_banner.jpg",
                ),
                SizedBox(width: 12),
                _PromoBannerCard(
                  imagePath: "assets/summer_banner.jpg",
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: "รูปภาพที่สถานที่ท่องเที่ยว"),

          // ✅ Places List (กดได้)
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: places.length,
              itemBuilder: (_, i) {
                final Map<String, dynamic> p = places[i];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CountryDetailPage(
                          name: p["name"] as String,
                          description: "เที่ยว ${p["name"]} ✨ บรรยากาศสุดพิเศษ",
                          images: List<String>.from(p["extra"] as List),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 150,
                    child: _PlaceCard(
                      name: p["name"] as String,
                      img: p["img"] as String,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          _SectionHeader(title: "สถานที่ท่องเที่ยว 🗺️✈️"),

          // ✅ Auto Sliding Uncontained Layout
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _placesController,
              itemCount: places.length,
              itemBuilder: (_, i) {
                final Map<String, dynamic> p = places[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(p["img"] as String, fit: BoxFit.cover),
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.all(8),
                          color: Colors.black.withOpacity(0.3),
                          child: Text(
                            p["name"] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Section Header Box
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xff1b263b),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ✅ Hero Banner Card
class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  final String title;
  final String subtitle;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white)),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

// ✅ การ์ดแบนเนอร์ (รูปเต็มกรอบ)
class _PromoBannerCard extends StatelessWidget {
  final String imagePath;

  const _PromoBannerCard({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge, // ✅ กันไม่ให้รูปเกินกรอบ
      child: SizedBox.expand(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover, // ✅ รูปเต็มกรอบ
        ),
      ),
    );
  }
}

// ✅ การ์ดสถานที่
class _PlaceCard extends StatelessWidget {
  final String name;
  final String img;
  const _PlaceCard({required this.name, required this.img});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
