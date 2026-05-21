import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'main.dart';
import 'reservation_page.dart';
import 'dart:async';
import 'dart:math';
import 'parking_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _ParkingListPage(),
    const MapPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A5276),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking),
            label: 'Parkinget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Harta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historiku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profili',
          ),
        ],
      ),
    );
  }
}

class _ParkingListPage extends StatefulWidget {
  const _ParkingListPage();

  @override
  State<_ParkingListPage> createState() => _ParkingListPageState();
}

class _ParkingListPageState extends State<_ParkingListPage> {

  Timer? _timer;

  @override
void initState() {
  super.initState();
  _updateParkingSpots();
  _timer = Timer.periodic(const Duration(minutes: 5), (_) {
    _updateParkingSpots();
  });
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateParkingSpots() async {
    final random = Random();
    final snapshot = await FirebaseFirestore.instance
        .collection('parkings')
        .get();
    for (var doc in snapshot.docs) {
      final newSpots = random.nextInt(15);
      await FirebaseFirestore.instance
          .collection('parkings')
          .doc(doc.id)
          .update({'spots': newSpots});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5276),
        title: const Text(
          'Smart Parking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5276),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mirë se erdhe! 👋',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Përdorues',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gjej vendin tënd të parkimit',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Parkinget e Disponueshme',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A5276),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('parkings')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1A5276)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Nuk ka parkinge të disponueshme'),
                  );
                }
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _parkingCard(
                      context,
                      docId: doc.id,
                      name: data['name'] ?? '',
                      address: data['address'] ?? '',
                      spots: data['spots'] ?? 0,
                      price: '${data['price']} L/orë',
                      distance: data['distance'] ?? '',
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _parkingCard(
    BuildContext context, {
    required String docId,
    required String name,
    required String address,
    required int spots,
    required String price,
    required String distance,
  }) {
    final bool isAvailable = spots > 0;

    return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailPage(
          docId: docId,
          name: name,
          address: address,
          spots: spots,
          price: price,
          distance: distance,
          imageUrl: null,
        ),
      ),
    );
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A5276),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAvailable ? '$spots vende' : 'Plot',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(address,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_money,
                      size: 14, color: Color(0xFFF39C12)),
                  Text(price,
                      style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFF39C12),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  const Icon(Icons.directions_walk,
                      size: 14, color: Colors.grey),
                  Text(distance,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                onPressed: isAvailable
                    ? () async {
                        await FirebaseFirestore.instance
                            .collection('parkings')
                            .doc(docId)
                            .update({
                          'spots': spots - 1,
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationPage(
                              parkingName: name,
                              address: address,
                              price: price,
                              spots: spots,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5276),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Rezervo',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}