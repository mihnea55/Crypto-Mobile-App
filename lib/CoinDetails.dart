  import 'package:flutter/material.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:fluttertoast/fluttertoast.dart';
  import 'CustomBottomNavBar.dart';
  import 'Profile.dart';
  import 'Homepage.dart';

  class CoinDetails extends StatefulWidget {
    final Map<String, dynamic> coin;

    const CoinDetails({super.key, required this.coin});

    @override
    _CoinDetailsState createState() => _CoinDetailsState();
  }

  class _CoinDetailsState extends State<CoinDetails> {
    int _selectedIndex = 0;
    double _amountOwned = 0.0;
    double _amountOwnedInMoney = 0.0;



    void _fetchAmountOwned() {
      FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('coinType', isEqualTo: widget.coin['name'])
          .snapshots()
          .listen((transactionsSnapshot) {
        double totalAmountOwned = 0.0;

        for (var transaction in transactionsSnapshot.docs) {
          double amountOfCoin = transaction['amountOfCoin'];
          String action = transaction['action'];

          print("Transaction found: " + action); // Debugging

          if (action == 'buy') {
            totalAmountOwned += amountOfCoin;
          } else if (action == 'sell') {
            totalAmountOwned -= amountOfCoin;
          }
        }

        double coinPrice = widget.coin['quote']['USD']['price'];
        double amountOwnedInMoney = totalAmountOwned * coinPrice;

        setState(() {
          _amountOwned = totalAmountOwned;
          _amountOwnedInMoney = amountOwnedInMoney;
        });

        print("Updated Amount Owned: $_amountOwned"); // Debugging
        print("Updated Value in Money: $_amountOwnedInMoney");
      });
    }

    // Function to handle Sell button press
    void _sellCrypto(BuildContext context) {
      TextEditingController amountController = TextEditingController();

      // Show dialog to enter amount for selling the crypto
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Amount to Sell ${widget.coin['name']}"),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter amount in EUR'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  double amount = double.tryParse(amountController.text) ?? 0.0;

                  if (amount <= 0) {
                    Fluttertoast.showToast(
                      msg: "Please enter a valid amount.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                    return;
                  }

                  // Get the current balance and owned amount of the coin
                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((document) async {
                    if (document.exists) {
                      double currentBalance = document['balance'].toDouble();

                      // Check the amount of crypto owned
                      double amountOwnedInCrypto = _amountOwned;

                      // Check if the user has enough crypto to sell
                      if (amount > (amountOwnedInCrypto * widget.coin['quote']['USD']['price'])) {
                        Fluttertoast.showToast(
                          msg: "Insufficient crypto to sell.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.SNACKBAR,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      // Calculate the amount of coin to be sold (in crypto units)
                      double coinPrice = widget.coin['quote']['USD']['price'];
                      double amountOfCoinToSell = amount / coinPrice;

                      // Check if the amount to sell is within the owned amount
                      if (amountOfCoinToSell > amountOwnedInCrypto) {
                        Fluttertoast.showToast(
                          msg: "You don't have enough crypto to sell.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.SNACKBAR,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      // Update the user's balance with the amount from the sale
                      double newBalance = currentBalance + amount;
                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                        'balance': newBalance,
                      });

                      await FirebaseFirestore.instance.collection('transactions').add({
                        'userId': FirebaseAuth.instance.currentUser!.uid,
                        'amountReceived': amount,
                        'symbol': widget.coin['symbol'],
                        'action': "sell",
                        'coinType': widget.coin['name'],
                        'amountOfCoin': amountOfCoinToSell,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      // Update the amount owned after selling
                      setState(() {
                        _amountOwned -= amountOfCoinToSell;
                        _amountOwnedInMoney = _amountOwned * coinPrice;
                      });

                      Fluttertoast.showToast(
                        msg: "Crypto sale successful.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "User not found.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    }
                  });

                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Sell"),
              ),
            ],
          );
        },
      );
    }
    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _fetchAmountOwned(); // Re-fetch whenever dependencies change (e.g., page revisit)
    }
    // Function to handle Buy button press
    void _buyCrypto(BuildContext context) {
      TextEditingController amountController = TextEditingController();

      // Show dialog to enter amount for buying the crypto
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter Amount to Buy ${widget.coin['name']}"),
            content: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter amount in EUR'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  double amount = double.tryParse(amountController.text) ?? 0.0;

                  if (amount <= 0) {
                    Fluttertoast.showToast(
                      msg: "Please enter a valid amount.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                    return;
                  }

                  // Get the current balance from Firestore
                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((document) async {
                    if (document.exists) {
                      double currentBalance = document['balance'].toDouble();

                      // Check if the user has enough balance
                      if (amount > currentBalance) {
                        Fluttertoast.showToast(
                          msg: "Insufficient balance.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.SNACKBAR,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        return;
                      }

                      // Calculate how much of the coin the user can buy
                      double coinPrice = widget.coin['quote']['USD']['price'];
                      double amountOfCoin = amount / coinPrice;

                      // Deduct the amount from the balance
                      double newBalance = currentBalance - amount;
                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                        'balance': newBalance,
                      });

                      // Add the transaction to Firestore
                      await FirebaseFirestore.instance.collection('transactions').add({
                        'userId': FirebaseAuth.instance.currentUser!.uid,
                        'amountSpent': amount,
                        'action': "buy",
                        'symbol': widget.coin['symbol'],
                        'coinType': widget.coin['name'],
                        'amountOfCoin': amountOfCoin,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      Fluttertoast.showToast(
                        msg: "Crypto purchase successful.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "User not found.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.SNACKBAR,
                        backgroundColor: Colors.black54,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    }
                  });

                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Buy"),
              ),
            ],
          );
        },
      );
    }

    // Function to handle navigation tap on the bottom navigation bar
    void _onTap(int index) {
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profilepage()),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      final String logoUrl =
          'https://s2.coinmarketcap.com/static/img/coins/64x64/${widget.coin['id']}.png';

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.coin['name']),
          backgroundColor: Color(0xFF1E1F22),
        ),
        backgroundColor: Color(0xFF1E1F22),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(logoUrl, width: 100, height: 100),
              SizedBox(height: 20),
              Text(
                widget.coin['name'],
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                'Price: \$${widget.coin['quote']['USD']['price'].toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
              SizedBox(height: 10),
              // Display the amount owned
              Text(
                'Amount Owned: ${_amountOwned.toStringAsFixed(4)} ${widget.coin['symbol']}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10),
              // Display the value in real money
              Text(
                'Value: \$${_amountOwnedInMoney.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Spacer(), // This pushes the buttons to the bottom of the screen
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _buyCrypto(context); // Trigger Buy crypto function
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green color for Buy button
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // No rounded corners
                      ),
                    ),
                    child: Text(
                      'Buy',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _sellCrypto(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red color for Sell button
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      'Sell',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20), // A little space at the bottom
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onTap, // Pass _onTap to the CustomBottomNavBar
        ),
      );
    }
  }

