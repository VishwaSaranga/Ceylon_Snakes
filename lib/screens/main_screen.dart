import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ceylon_snakes/screens/home_screen.dart';
import 'package:ceylon_snakes/screens/emergency_screen.dart';
import 'package:ceylon_snakes/screens/hospital_screen.dart';
import 'package:ceylon_snakes/screens/library_screen.dart';
import 'package:ceylon_snakes/screens/history_screen.dart';
import 'package:ceylon_snakes/screens/favorites_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _callAmbulance() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '1990',
    );
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch emergency call');
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of screens for the navigation
    final List<Widget> screens = [
      HomeScreen(onTabChange: _navigateToTab),
      const EmergencyScreen(isTab: true),
      const HospitalScreen(isTab: true),
      const LibraryScreen(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF145A32),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', height: 60),
                      const SizedBox(height: 10),
                      const Text(
                        'Ceylon Snakes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text('Safety Tips'),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text('Scan History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HistoryScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_outline_rounded),
                title: const Text('Favorites'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoritesScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.book_outlined),
                title: const Text('Snake Library'),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(3);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_hospital_outlined),
                title: const Text('Hospitals'),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(2);
                },
              ),
              const Spacer(),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2ECC71),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety_outlined),
              label: 'Safety Tips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.my_location),
              label: 'Hospitals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Library',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _callAmbulance,
          backgroundColor: const Color(0xFFE74C3C), // Red color
          child: const Icon(Icons.call, color: Colors.white),
        ),
      ),
    );
  }
}
