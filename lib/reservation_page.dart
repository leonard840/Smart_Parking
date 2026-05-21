import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'payment_page.dart';
class ReservationPage extends StatefulWidget {
  final String parkingName;
  final String address;
  final String price;
  final int spots;

  const ReservationPage({
    super.key,
    required this.parkingName,
    required this.address,
    required this.price,
    required this.spots,
  });

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  int _hours = 1;
 bool _isLoading = false;
String? _qrCode;
String? _reservationId;
int _discount = 0;

@override
void initState() {
  super.initState();
  _loadDiscount();
}

Future<void> _loadDiscount() async {
  final user = FirebaseAuth.instance.currentUser;
  final snapshot = await FirebaseFirestore.instance
      .collection('reservations')
      .where('userId', isEqualTo: user!.uid)
      .get();
  final count = snapshot.docs.length;
  setState(() {
    if (count >= 10) {
      _discount = 20;
    } else if (count >= 3) {
      _discount = 10;
    } else {
      _discount = 0;
    }
  });
}

  int _getPrice() {
  try {
    final priceStr = widget.price.replaceAll(RegExp(r'[^0-9]'), '');
    if (priceStr.isEmpty) return 0;
    final basePrice = int.parse(priceStr) * _hours;
    return (basePrice * (100 - _discount) / 100).round();
  } catch (e) {
    return 0;
  }
}

  @override
  Widget build(BuildContext context) {
    if (_qrCode != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F3F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A5276),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Rezervimi u Krye!',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 60),
                    const SizedBox(height: 12),
                    const Text(
                      'Rezervimi u Konfirmua!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A5276),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.parkingName,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'QR Code për hyrje në parking:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF1A5276), width: 2),
                      ),
                      child: QrImageView(
                        data: _qrCode!,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ID: ${_reservationId!.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Parking:',
                                  style: TextStyle(color: Colors.grey)),
                              Text(widget.parkingName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Orët:',
                                  style: TextStyle(color: Colors.grey)),
                              Text('$_hours orë',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Totali:',
                                  style: TextStyle(color: Colors.grey)),
                              Text(
                                '${_getPrice()} L',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF39C12),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
               SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton.icon(
    onPressed: () async {
      final encodedAddress = Uri.encodeComponent(widget.address);
      final url = 'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress';
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    },
    icon: const Icon(Icons.navigation, color: Colors.white),
    label: const Text(
      'Navigo drejt Parkingut',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      minimumSize: const Size(double.infinity, 50),
    ),
  ),
),
const SizedBox(height: 12),
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () {
      Navigator.pop(context);
      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1A5276),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: const Text(
      'Kthehu në Faqen Kryesore',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  ),
),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5276),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Rezervo Vendin',
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
                    'Detajet e Parkingut',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.parkingName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        widget.address,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          size: 14, color: Color(0xFFF39C12)),
                      Text(
                        widget.price,
                        style: const TextStyle(
                          color: Color(0xFFF39C12),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text(
                    'Sa orë do të parkosh?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A5276),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_hours > 1) setState(() => _hours--);
                        },
                        icon: const Icon(Icons.remove_circle,
                            color: Color(0xFF1A5276), size: 36),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_hours orë',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5276),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          if (_hours < 12) setState(() => _hours++);
                        },
                        icon: const Icon(Icons.add_circle,
                            color: Color(0xFF1A5276), size: 36),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Çmimi për orë:',
                          style: TextStyle(color: Colors.grey)),
                      Text(widget.price,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Numri i orëve:',
                          style: TextStyle(color: Colors.grey)),
                      Text('$_hours orë',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_discount > 0)
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        _discount == 20 ? '🥇 Gold Member:' : '🥈 Silver Member:',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        '-$_discount%',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
const SizedBox(height: 8),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Totali:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A5276),
                        ),
                      ),
                      Text(
                        '${_getPrice()} L',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF39C12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
           SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: _isLoading ? null : () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentPage(
            parkingName: widget.parkingName,
            address: widget.address,
            price: widget.price,
            spots: widget.spots,
            hours: _hours,
            totalPrice: _getPrice(),
            discount: _discount,
          ),
        ),
      );
    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF39C12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Konfirmo Rezervimin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}