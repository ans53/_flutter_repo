import 'package:flutter/material.dart';
import 'package:lifeshareapplication/home.dart';
import 'package:lifeshareapplication/my_donation.dart';
import 'package:lifeshareapplication/request_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTabbar extends StatefulWidget {
  const MyTabbar({super.key});

  @override
  State<MyTabbar> createState() => _MyTabbarState();
}

class _MyTabbarState extends State<MyTabbar> {
  final List<Widget> _pageOptions = const [HomePage(), Requests(), MyDonationRequest()];

  int _selectedIndex = 0;
  bool _isLoggedIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLoggedIn().then((loggedIn) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _buildMyTabPage(context);
  }

  Widget _buildMyTabPage(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: const AlwaysStoppedAnimation<double>(1),
        child: _pageOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        iconSize: 30,
        selectedLabelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        backgroundColor: Colors.amber.shade600,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
            backgroundColor: Colors.amber,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_sharp),
            label: 'Requests',
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.wallet_giftcard),
            label: 'Donor Request',
            backgroundColor: Colors.teal[600],
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
