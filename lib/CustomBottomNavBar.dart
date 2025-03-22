import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  CustomBottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF2A2D32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: selectedIndex == 0 ? Color(0xFF15EED2) : Colors.white),
            onPressed: () => onTap(0),
          ),
          FloatingActionButton(
            onPressed: () {
              _showPopup(context);
            },
            backgroundColor: Color(0xFF15EED2),
            elevation: 10.0,
            shape: CircleBorder(),
            child: Icon(Icons.add, color: Colors.white),
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: selectedIndex == 1 ? Color(0xFF15EED2) : Colors.white),
            onPressed: () => onTap(1),
          ),
        ],
      ),
    );
  }

  // Function to show the popup when the FAB is pressed
  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Action"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the popup
                  _showAmountDialog(context, "Add");
                },
                child: Text("Add"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the popup
                  _showAmountDialog(context, "Withdraw");
                },
                child: Text("Withdraw"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show the text field and buttons for Add/Withdraw
  void _showAmountDialog(BuildContext context, String action) {
    TextEditingController amountController = TextEditingController();
    double currentBalance = 0.0;  // To store the current balance of the user.

    // Fetch the current balance from Firestore
    FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get().then((document) {
      if (document.exists) {
        currentBalance = document['balance'].toDouble();  // Fetch the balance.
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$action Amount"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                ),
              ),
            ],
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
                  // Handle invalid input
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

                if (action == "Withdraw") {
                  // Check if balance is sufficient for withdrawal
                  if (amount > currentBalance) {
                    Fluttertoast.showToast(
                      msg: "Insufficient balance for withdrawal.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.SNACKBAR,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                    return;
                  }

                  // Deduct the amount from the balance
                  double newBalance = currentBalance - amount;
                  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                    'balance': newBalance,
                  });

                  Fluttertoast.showToast(
                    msg: "Withdrawal successful.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                } else if (action == "Add") {
                  // Add the amount to the balance
                  double newBalance = currentBalance + amount;
                  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update({
                    'balance': newBalance,
                  });

                  Fluttertoast.showToast(
                    msg: "Amount added successfully.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                }

                Navigator.pop(context); // Close the dialog
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}
