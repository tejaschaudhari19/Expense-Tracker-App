import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  // Fetch transactions from Firebase based on the transaction type
  Future<List<Map<String, dynamic>>> fetchTransactions(String type) async {
    try {
      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user is logged in',
        );
      }

      // Reference the transactions for the user
      final DatabaseReference dbRef =
      FirebaseDatabase.instance.ref('transactions/${user.uid}');

      final DatabaseEvent event = await dbRef.once();

      // Parse the data
      if (event.snapshot.value != null) {
        final Map<String, dynamic>? data =
        Map<String, dynamic>.from(event.snapshot.value as Map);

        // Filter transactions based on type (Credit/Debit)
        final List<Map<String, dynamic>> filteredTransactions = data!.entries
            .where((entry) => entry.value['type'] == type)
            .map((entry) => {
          'id': entry.key,
          ...Map<String, dynamic>.from(entry.value),
        })
            .toList();

        return filteredTransactions;
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate back to HomeScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          title: const Text("Transaction Records"),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Credits"),
              Tab(text: "Debits"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Credits Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchTransactions("Credit"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Error loading credits: ${snapshot.error.toString()}"));
                }
                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Credits Found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      title: Text("₹${transaction['amount']}"),
                      subtitle:
                      Text(transaction['description'] ?? "No description"),
                      trailing: Text(transaction['date'] != null
                          ? DateTime.parse(transaction['date'])
                          .toLocal()
                          .toString()
                          .split(' ')[0]
                          : "Unknown Date"),
                    );
                  },
                );
              },
            ),

            // Debits Tab
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchTransactions("Debit"),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          "Error loading debits: ${snapshot.error.toString()}"));
                }
                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Debits Found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return ListTile(
                      title: Text("₹${transaction['amount']}"),
                      subtitle:
                      Text(transaction['description'] ?? "No description"),
                      trailing: Text(transaction['date'] != null
                          ? DateTime.parse(transaction['date'])
                          .toLocal()
                          .toString()
                          .split(' ')[0]
                          : "Unknown Date"),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}