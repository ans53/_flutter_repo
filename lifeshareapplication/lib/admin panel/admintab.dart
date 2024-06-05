import 'package:flutter/material.dart';
import 'package:lifeshareapplication/admin%20panel/admin_login.dart';
import 'package:lifeshareapplication/admin%20panel/approveddetails.dart';
import 'package:lifeshareapplication/admin%20panel/consent.dart';
import 'package:lifeshareapplication/admin%20panel/donor_record.dart';
import 'package:lifeshareapplication/admin%20panel/recipient_record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAdminTabbar extends StatefulWidget {
  const MyAdminTabbar({super.key});

  @override
  State<MyAdminTabbar> createState() => _MyAdminTabbarState();
}

class _MyAdminTabbarState extends State<MyAdminTabbar> {
  final _pageOptions = const [DonorRecord(), RecipientRecord(), ApprovedDetails(), ConsentUpload()];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedInAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return _buildMyTabPage(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
            );
            return Container();
          }
        } else {
          // Handle loading state if needed
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildMyTabPage(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _pageOptions[_selectedIndex],
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          iconSize: 25,
          selectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          backgroundColor: Colors.amber.shade600,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_rounded),
              label: 'Donors',
              backgroundColor: Colors.amber,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined),
              label: 'Recipients',
              backgroundColor: Colors.teal,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.gpp_good),
              label: 'Approved Donors',
              backgroundColor: Colors.teal,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_sharp),
              label: 'Upload Consent',
              backgroundColor: Colors.orange,
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Future<bool> isLoggedInAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
