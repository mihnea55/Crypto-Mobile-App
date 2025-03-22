import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Profile.dart';
import 'CustomBottomNavBar.dart';
import 'CoinDetails.dart';



class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  List<dynamic> _coins = [];
  List<dynamic> _filteredCoins = [];
  bool _isLoading = true;
  final String apiKey = '0e235564-4924-43b1-8988-93da39b38735';

  @override
  void initState() {
    super.initState();
    _fetchCoins();
  }

  Future<void> _fetchCoins() async {
    try {
      final response = await http.get(
        Uri.parse('https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=500'),
        headers: {'X-CMC_PRO_API_KEY': apiKey},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _coins = data['data'];
          _filteredCoins = _coins;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching coins: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filteredCoins = _coins.where((coin) {
        final name = coin['name'].toLowerCase();
        final symbol = coin['symbol'].toLowerCase();
        return name.contains(query.toLowerCase()) || symbol.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Profilepage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1F22),
      appBar: AppBar(
        backgroundColor: Color(0xFF1E1F22),
        title: TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF2B2D30),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search, color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: _onSearch,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredCoins.isEmpty
          ? Center(
        child: Text(
          'No coins found',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _filteredCoins.length,
        itemBuilder: (context, index) {
          final coin = _filteredCoins[index];
          final String logoUrl =
              'https://s2.coinmarketcap.com/static/img/coins/64x64/${coin['id']}.png';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white24,
              backgroundImage: NetworkImage(logoUrl),
            ),
            title: Text(
              coin['name'],
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              '\$${coin['quote']['USD']['price'].toStringAsFixed(2)}',
              style: TextStyle(color: Colors.green),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoinDetails(coin: coin),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
