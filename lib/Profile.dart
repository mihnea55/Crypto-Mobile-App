import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CustomBottomNavBar.dart';
import 'Homepage.dart';
import 'main.dart';

class Profilepage extends StatefulWidget {
  Profilepage({super.key});

  @override
  _ProfilepageState createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  int _selectedIndex = 1;
  double _balance = 0.0;
  Map<String, Map<String, dynamic>> _ownedCoins = {};
  Map<String, String> _coinLogos = {};
  List<dynamic> _coins = [];
  bool _isLoading = true;

  final String apiKey = '0e235564-4924-43b1-8988-93da39b38735';

  @override
  void initState() {
    super.initState();
    _fetchCoins().then((_) => _fetchOwnedCoins());
    _fetchUserData();
  }


  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homepage()),
      );
    }
  }

  void _fetchUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            _balance = snapshot.data()?['balance']?.toDouble() ?? 0.0;
          });
        }
      });
    }
  }

  void _fetchOwnedCoins() async {
    if (_coins.isEmpty) {
      await _fetchCoins();
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) async {
        Map<String, Map<String, dynamic>> ownedCoins = {};

        for (var doc in snapshot.docs) {
          var data = doc.data();
          String coinType = data['coinType'] ?? 'Unknown';
          double amount = (data['amountOfCoin'] as num?)?.toDouble() ?? 0.0;
          String action = data['action'].toString().toLowerCase();
          String coinSymbol = data['symbol'] ?? 'N/A';

          double coinPriceUSD = 0.0;
          for (var coin in _coins) {
            if (coin['symbol'] == coinSymbol) {
              coinPriceUSD = coin['quote']['USD']['price']?.toDouble() ?? 0.0;
              break;
            }
          }

          if (!ownedCoins.containsKey(coinType)) {
            ownedCoins[coinType] = {
              'amount': 0.0,
              'symbol': coinSymbol,
              'valueInUSD': 0.0,
              'logoUrl': data['logoUrl'] ?? '',
            };
          }

          if (action == 'buy') {
            ownedCoins[coinType]!['amount'] =
                (ownedCoins[coinType]!['amount'] ?? 0.0) + amount;
          } else if (action == 'sell') {
            ownedCoins[coinType]!['amount'] =
                (ownedCoins[coinType]!['amount'] ?? 0.0) - amount;
          }


          ownedCoins[coinType]!['valueInUSD'] =
              (ownedCoins[coinType]!['amount'] ?? 0.0) * coinPriceUSD;
        }


        ownedCoins.removeWhere((key, value) => value['amount']! <= 0);

        setState(() {
          _ownedCoins = ownedCoins;
        });
      });
    }
  }


  Future<void> _fetchCoins() async {
    final String url =
        'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?CMC_PRO_API_KEY=$apiKey&limit=50'; // Limit to 50 coins for this example

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);print('API Response: $data');

        final List<dynamic> coinsList = data['data'];('Coins data fetched successfully: ${coinsList.length} coins');


        _coins = coinsList;

        _updateCoinLogos();
      }
    } catch (e) {

    }
  }

  void _updateCoinLogos() {
    for (var coin in _coins) {
      String symbol = coin['symbol'];
      String logoUrl = 'https://s2.coinmarketcap.com/static/img/coins/64x64/${coin['id']}.png';
      if (logoUrl.isNotEmpty) {
        setState(() {
          _coinLogos[symbol] = logoUrl;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1F22),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Balance: $_balance €', style: const TextStyle(color: Colors.green, fontSize: 18)),
            const SizedBox(height: 20),

            _ownedCoins.isEmpty
                ? const Center(child: Text('No owned coins.', style: TextStyle(color: Colors.white)))
                : Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Owned Coins',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: _ownedCoins.entries.map((entry) {
                        String coinSymbol = entry.value['symbol'] ?? '';
                        String logoUrl = _coinLogos[coinSymbol] ?? '';

                        return ListTile(
                          leading: logoUrl.isNotEmpty
                              ? Image.network(logoUrl, width: 30, height: 30)
                              : const Icon(Icons.error, color: Colors.white),
                          title: Text(
                            '${entry.key} ($coinSymbol)',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.value['amount'].toStringAsFixed(4)}', style: const TextStyle(color: Colors.green)),
                              Text('Value: \$${entry.value['valueInUSD'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.blue)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
              child: const Text('Sign Out', style: TextStyle(fontSize: 22, color: Colors.white)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onTap: _onTap),
    );
  }
}
