import 'package:flutter/material.dart';
import 'package:ceylon_snakes/screens/main_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    this.currentIndex = -1, // -1 means no item is highlighted
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex == -1 ? 0 : currentIndex,
      onTap: (index) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(initialIndex: index)),
          (route) => false,
        );
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor:
          currentIndex == -1 ? Colors.grey : const Color(0xFF2ECC71),
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
    );
  }
}
