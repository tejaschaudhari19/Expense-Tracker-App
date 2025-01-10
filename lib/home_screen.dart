import 'package:iraje_app/add_transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iraje_app/home_page.dart';
import 'package:iraje_app/records_page.dart';
import 'package:iraje_app/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const RecordsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        backgroundColor: Colors.blue.shade300,
        title: const Text(
          "Expense Insight",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionPage(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 30),
        backgroundColor: Colors.blue.shade700,
      )
          : null,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: GNav(
          rippleColor: Colors.blueAccent,
          color: Colors.blue.shade800.withOpacity(0.8),
          activeColor: Colors.white,
          tabBackgroundColor: Colors.blue.shade700.withOpacity(0.6),
          haptic: true,
          gap: 8,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          tabs: const [
            GButton(
              icon: Icons.home_rounded,
              text: "Home",
              iconColor: Colors.blueAccent,
            ),
            GButton(
              icon: Icons.list,
              text: "Records",
              iconColor: Colors.blueAccent,
            ),
            GButton(
              icon: Icons.person_rounded,
              text: "Profile",
              iconColor: Colors.blueAccent,
            ),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}