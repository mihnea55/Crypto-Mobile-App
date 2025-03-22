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

          print("Transaction found: " + action);



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

        print("Updated Amount Owned: $_amountOwned");
        print("Updated Value in Money: $_amountOwnedInMoney");
      });
    }

    void _sellCrypto(BuildContext context) {
      TextEditingController amountController = TextEditingController();


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
                  Navigator.pop(context);
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

                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((document) async {
                    if (document.exists) {
                      double currentBalance = document['balance'].toDouble();


                      double amountOwnedInCrypto = _amountOwned;

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

                      double coinPrice = widget.coin['quote']['USD']['price'];
                      double amountOfCoinToSell = amount / coinPrice;

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

                  Navigator.pop(context);
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
      _fetchAmountOwned();
    }

    void _buyCrypto(BuildContext context) {
      TextEditingController amountController = TextEditingController();


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
                  Navigator.pop(context);

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


                  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((document) async {
                    if (document.exists) {
                      double currentBalance = document['balance'].toDouble();

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

                      double coinPrice = widget.coin['quote']['USD']['price'];
                      double amountOfCoin = amount / coinPrice;

                      double newBalance = currentBalance - amount;
                      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                        'balance': newBalance,
                      });

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

                  Navigator.pop(context);
                },
                child: Text("Buy"),
              ),
            ],
          );
        },
      );
    }

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

              Text(
                'Amount Owned: ${_amountOwned.toStringAsFixed(4)} ${widget.coin['symbol']}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 10),


              Text(
                'Value: \$${_amountOwnedInMoney.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _buyCrypto(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
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
                      backgroundColor: Colors.red,
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
              SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onTap,
        ),
      );
    }
  }

