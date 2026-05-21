import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final String parkingName;
  final String address;
  final String price;
  final int spots;
  final int hours;
  final int totalPrice;
  final int discount;

  const PaymentPage({
    super.key,
    required this.parkingName,
    required this.address,
    required this.price,
    required this.spots,
    required this.hours,
    required this.totalPrice,
    required this.discount,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _paymentMethod = 'card';
  bool _isLoading = false;
  String? _qrCode;
  String? _reservationId;

  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  Future<void> _confirmPayment() async {
    if (_paymentMethod == 'card') {
      if (_cardNumberController.text.length < 16 ||
          _cardNameController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ju lutem plotësoni të gjitha fushat e kartës!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final docRef = await FirebaseFirestore.instance
          .collection('reservations')
          .add({
        'userId': user!.uid,
        'userEmail': user.email,
        'parkingName': widget.parkingName,
        'address': widget.address,
        'price': widget.price,
        'hours': widget.hours,
        'totalPrice': widget.totalPrice,
        'discount': widget.discount,
        'paymentMethod': _paymentMethod == 'card' ? 'Kartë' : 'Cash',
        'status': 'active',
        'createdAt': Timestamp.now(),
      });

      setState(() {
        _reservationId = docRef.id;
        _qrCode =
            'SMARTPARKING-${docRef.id}-${user.uid}-${widget.parkingName}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gabim: ${e.toString()}')),
      );
    }
    setState(() => _isLoading = false);
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
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'card'
                            ? Colors.blue.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _paymentMethod == 'card'
                            ? '💳 Paguar me Kartë'
                            : '💵 Paguhet Cash te Parkingu',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _paymentMethod == 'card'
                              ? Colors.blue
                              : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'QR Code për hyrje në parking:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
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
                              Text('${widget.hours} orë',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (widget.discount > 0) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.discount == 20
                                      ? '🥇 Gold Member:'
                                      : '🥈 Silver Member:',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '-${widget.discount}%',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Totali:',
                                  style: TextStyle(
                                      color: Colors.grey)),
                              Text(
                                '${widget.totalPrice} L',
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
                          final encodedAddress =
                              Uri.encodeComponent(widget.address);
                          final url =
                              'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.navigation,
                            color: Colors.white),
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
  Navigator.of(context).popUntil((route) => route.isFirst);
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
          'Pagesa',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A5276),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detajet e Rezervimit',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(widget.parkingName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${widget.hours} orë  •  ${widget.totalPrice} L',
                      style: const TextStyle(
                          color: Color(0xFFF39C12),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Zgjidh Metodën e Pagesës',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A5276),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _paymentMethod = 'card'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'card'
                            ? const Color(0xFF1A5276)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1A5276),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.credit_card,
                              size: 32,
                              color: _paymentMethod == 'card'
                                  ? Colors.white
                                  : const Color(0xFF1A5276)),
                          const SizedBox(height: 8),
                          Text('Kartë',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _paymentMethod == 'card'
                                    ? Colors.white
                                    : const Color(0xFF1A5276),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _paymentMethod = 'cash'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _paymentMethod == 'cash'
                            ? const Color(0xFF1A5276)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1A5276),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.money,
                              size: 32,
                              color: _paymentMethod == 'cash'
                                  ? Colors.white
                                  : const Color(0xFF1A5276)),
                          const SizedBox(height: 8),
                          Text('Cash',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _paymentMethod == 'cash'
                                    ? Colors.white
                                    : const Color(0xFF1A5276),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_paymentMethod == 'card') ...[
              const Text(
                'Të Dhënat e Kartës',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A5276),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardNameController,
                decoration: InputDecoration(
                  labelText: 'Emri në Kartë',
                  prefixIcon: const Icon(Icons.person,
                      color: Color(0xFF1A5276)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1A5276), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: InputDecoration(
                  labelText: 'Numri i Kartës',
                  prefixIcon: const Icon(Icons.credit_card,
                      color: Color(0xFF1A5276)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF1A5276), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      maxLength: 5,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        prefixIcon: const Icon(Icons.calendar_today,
                            color: Color(0xFF1A5276)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF1A5276), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      maxLength: 3,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        prefixIcon: const Icon(Icons.lock,
                            color: Color(0xFF1A5276)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF1A5276), width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (_paymentMethod == 'cash') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.green, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Do të paguash cash direkt te parkingu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'QR Code do të gjenerohet menjëherë dhe do ta tregosh te hyrja e parkingut.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.green, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF39C12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : Text(
                        _paymentMethod == 'card'
                            ? 'Paguaj ${widget.totalPrice} L'
                            : 'Konfirmo Rezervimin',
                        style: const TextStyle(
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